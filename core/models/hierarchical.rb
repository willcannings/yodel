module Yodel
  class Hierarchical < Record
    belongs_to :parent, class: self
    has_many :children, class: self, dependent: :destroy, order: 'index asc', foreign_key: 'parent_id'
    key :index, Integer, required: true, display: false
    ensure_index 'parent_id'
    
    # tree walking; performed as recursion because iterative traversal is verbose
    def all_children
      @all_children ||= children + children.inject([]) {|records, child| records + child.all_children}
    end
    
    def siblings
      @siblings ||= Hierarchical.all parent_id: parent.id, order: 'key asc'
    end
    
    def ancestors
      @ancestors ||= [self] + (self.parent.try(:ancestors) || [])
    end
    
    def root?
      self.parent.nil?
    end
    
    
    # insertion and deletion to maintin the integrity of the 'index' field
    before_destroy :remove_from_parent
    def remove_from_parent
      self.parent.remove_child(self)
    end

    def append_child(child)
    end

    def insert_child(child)
      # handle case where child.parent != self, and we're moving a record
    end
    
    def remove_child(child)
    end
    
    def move_to(new_index)
    end
    
    
    # it's sometimes necessary to restrict the type of records which can appear
    # below a record of a certain type. override these methods as necessary
    def self.allowed_child_types(*args, &block)
      if block_given?
        @allowed_child_types = yield
      elsif args.length >= 1
        @allowed_child_types = args.first
      else
        @allowed_child_types ||= descendents
      end
    end
    
    def self.default_child_type(*args, &block)
      if block_given?
        @default_child_type = yield
      elsif args.length >= 1
        @default_child_type = args.first
      else
        @default_child_type ||= self
      end
    end
    
    
    # some types may or may not allow more than one root per site, and may or
    # may not be able to act as a root for a site at all
    def self.multiple_roots?
      @multiple_roots
    end
    
    def self.multiple_roots
      @multiple_roots = true
      @can_be_root = true
    end
    
    def self.single_root
      @multiple_roots = false
    end
    
    def self.can_be_root?
      @can_be_root
    end
    
    def self.cannot_be_root
      @can_be_root = false
      @multiple_roots = false
    end
    
    def self.can_be_root
      @can_be_root = true
    end
    
    
    # copy class instance attributes down the inheritance chain
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@multiple_roots', @multiple_roots)
      child.instance_variable_set('@can_be_root', @can_be_root)
      child.instance_variable_set('@default_child_type', @default_child_type)
      child.instance_variable_set('@allowed_child_types', @allowed_child_types)
    end
  end
end
