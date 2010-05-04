module Yodel
  class Group < Hierarchical
    multiple_roots
    creatable
    key :name, String, required: true
    
    default_child_type Yodel::User
    allowed_child_types do
      [Yodel::User, *Yodel::User.descendents, self, *self.descendents]
    end
  end
end
