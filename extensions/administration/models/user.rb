module Yodel
  class User < Hierarchical
    allowed_child_types nil
    creatable

    key :username, String, required: true, index: true
    key :password, Password, required: true, searchable: false    
    
    def name
      self.username
    end
    
    def icon
      '/admin_static/images/user_icon.png'
    end
  end
end
