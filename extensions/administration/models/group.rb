module Yodel
  class Group < Hierarchical
    multiple_roots
    creatable
    key :name, String, required: true
    
    default_child_type  Yodel::User
    allowed_child_types self, Yodel::User
    
    def icon
      '/admin_static/images/group_icon.png'
    end
  end
end
