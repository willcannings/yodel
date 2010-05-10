module Yodel
  class User < Hierarchical
    cannot_be_root
    creatable
    key :username, String, required: true, index: true
    key :password, Password, required: true
    
    default_child_type  nil
    allowed_child_types nil
    
    def name
      self.username
    end
    
    def icon
      '/admin_static/images/user_icon.png'
    end
  end
end
