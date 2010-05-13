module Yodel
  class Group < Hierarchical
    allowed_child_types self, Yodel::User
    multiple_roots
    creatable
    
    key :name, String, required: true
    
    def icon
      '/admin/images/group_icon.png'
    end
  end
end
