module Yodel
  class Hierarchical < Record
    belongs_to :parent, class: Hierarchical
    has_many :children, class: Hierarchical, dependent: :destroy, order: 'key asc'
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
  end
end
