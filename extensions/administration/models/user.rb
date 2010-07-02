module Yodel
  class User < Hierarchical
    allowed_child_types nil
    creatable

    key :first_name, String
    key :last_name, String
    key :email, Email, required: true, unique: true # FIXME: needs to be unique over a site only
    key :username, String, required: true, index: true, unique: true # FIXME: needs to be unique over a site only
    key :password, Password, required: true, searchable: false
    
    def name
      "#{self.first_name} #{self.last_name}".strip
    end
    
    def icon
      '/admin/images/user_icon.png'
    end
  end
end
