module Yodel
  class Hierarchical < Record
    belongs_to :parent, class: Yodel::Record
    has_many :children, class: Yodel::Record, dependent: :destroy, order: 'index asc', foreign_key: 'parent_id'
    key :index, Integer, required: true, display: false
    ensure_index 'parent_id'
    
    def self.roots_for_site(site)
      self.all_for_site(site, parent_id: nil, order: 'index asc')
    end
    
    # tree walking; performed as recursion because iterative traversal is verbose
    def all_children
      @all_children ||= children + children.inject([]) {|records, child| records + child.all_children}
    end
    
    def siblings
      unless self.parent_id.nil? || self.parent_id.blank?
        @siblings ||= Record.all parent_id: BSON::ObjectID.from_string(self.parent_id.to_s), order: 'index asc'
      else
        # FIXME: once proper STI is implemented, we can actually return back siblings
        @siblings ||= [] #Record.all parent_id: nil order: 'index asc'
      end
    end
    
    # FIXME: overriding a built in method, should be renamed parents, or ancestor_records or something similar
    def ancestors
      @ancestors ||= [self] + (self.parent.try(:ancestors) || [])
    end
    
    def root?
      if defined?(self.parent_id)
        self.parent.nil?
      else
        self.parent = nil
        true
      end
    end
    
    def root_record
      self.ancestors[-1]
    end
    
    
    # insertion and deletion to maintin the integrity of the 'index' field
    before_destroy :remove_from_parent
    def remove_from_parent
      if root?
        remove_from_root
      else
        self.parent.remove_child(self)
      end
    end
    
    before_validation_on_create :add_to_parent
    def add_to_parent
      if root?
        append_to_root
      else
        self.parent.append_child(self)
      end
    end

    # FIXME: need to do extra checks; e.g append_to_root needs
    # to check if parent and index are set, and if so remove the
    # record from the existing collection
    def append_child(child)
      append_to_siblings(children, child)
      child.parent = self
    end
    
    def append_to_root
      append_to_siblings(self.class.roots_for_site(self.site), self)
      self.parent = nil
    end
    
    def append_to_siblings(siblings, record)
      highest_index = siblings.last.try(:index) || 0
      record.index = highest_index + 1
    end
    
    def insert_child(child, index)
      insert_in_siblings(children, child, index)
      child.parent = self
    end
    
    def insert_in_root(index)
      insert_in_siblings(self.class.roots_for_site(self.site), self, index)
      self.parent = nil
    end
    
    def insert_in_siblings(siblings, record, index)
      if record.index
        record.parent.remove_child(child) if !root?
        record.remove_from_root if root?
      end
      
      siblings.each do |sibling|
        if sibling.index >= index
          sibling.index += 1
          sibling.save
        end
      end
      record.index = index
    end
    
    def remove_child(child)
      remove_from_siblings(children, child)
    end
    
    def remove_from_root
      remove_from_siblings(self.class.roots_for_site(self.site), self)
    end
    
    def remove_from_siblings(siblings, record)
      siblings.each do |sibling|
        if sibling.index > record.index
          sibling.index -= 1
          sibling.save
        end
      end
      record.index  = nil
      record.parent = nil
    end
    
    def move_to(new_index)
      if root?
        remove_from_root
        insert_in_root(new_index)
      else
        self.parent.remove_child(self)
        self.parent.insert_child(self, new_index)
      end
    end
    
    
    # it's sometimes necessary to restrict the type of records which can appear
    # below a record of a certain type. override these methods as necessary
    def self.allowed_child_types(*args, &block)
      if block_given?
        @allowed_child_types = yield
      elsif args.length >= 1 && !args.first.nil?
        @allowed_child_types = args
      elsif args.length == 1 && args.first.nil?
        @allowed_child_types = nil
      else
        # conditional assignment will trigger when a value is nil. since this
        # is an acceptable value for child types, we check if the types have
        # been defined yet, and if so return, otherwise assign descendants of
        # this type by default. contrast to:
        # @allowed_child_types ||= descendants
        # the list is ORd with an empty list so enumeration can be guaranteed
        if defined?(@allowed_child_types)
          @allowed_child_types || []
        else
          @allowed_child_types = self_and_descendants
        end
      end
    end
    
    def self.allowed_child_types_and_descendants
      unless @allowed_child_types_and_descendants
        @allowed_child_types_and_descendants = allowed_child_types.collect do |child_type|
          [child_type, *child_type.descendants]
        end.flatten
      end
      @allowed_child_types_and_descendants
    end
    
    
    # some types may or may not allow more than one root per site, and may or
    # may not be able to act as a root for a site at all
    def self.multiple_roots?
      @multiple_roots
    end
    
    def self.multiple_roots
      @multiple_roots = true
    end
    
    def self.single_root
      @multiple_roots = false
    end
        
    # copy class instance attributes down the inheritance chain
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@multiple_roots', @multiple_roots)
      child.instance_variable_set('@allowed_child_types', @allowed_child_types)
    end
  end
end
