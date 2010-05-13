module Yodel
  class User < Hierarchical
    allowed_child_types nil
    creatable

    key :first_name, String
    key :last_name, String
    key :emai, Email
    key :username, String, required: true, index: true
    key :password, Password, required: true, searchable: false
    
    def name
      "#{self.first_name} #{self.last_name}".strip
    end
    
    def icon
      '/admin/images/user_icon.png'
    end
  end
end
