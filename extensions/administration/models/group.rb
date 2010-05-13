module Yodel
  class Group < Hierarchical
    allowed_child_types self, Yodel::User
    multiple_roots
    creatable
    
    key :name, String, required: true
    
    def icon
      '/admin_static/images/group_icon.png'
    end
  end
end
