module Yodel
  class User < Hierarchical
    SALT_ALPHABET = (65..90).to_a
    SALT_LENGTH = 40
    PASS_LENGTH = 8
    allowed_child_types nil
    creatable

    key :first_name, String
    key :last_name, String
    key :email, Email, required: true, unique: true # FIXME: needs to be unique over a site only
    key :username, String, required: true, index: true, unique: true # FIXME: needs to be unique over a site only
    key :password, Password, required: true, searchable: false
    key :password_salt, String, display: false
    
    def name
      "#{self.first_name} #{self.last_name}".strip
    end
    
    def icon
      '/admin/images/user_icon.png'
    end
    
    # create a random salt for new users
    before_create :create_salt_and_hash_password
    def create_salt_and_hash_password
      self.password_salt = ''
      SALT_LENGTH.times {self.password_salt += SALT_ALPHABET.sample.chr}
      self.password_salt = Digest::SHA1.hexdigest(self.password_salt)
      hash_password
    end

    # whenever the password is updated, re-hash it
    before_save :hash_password
    def hash_password
      return unless password_changed? && !password_salt.nil? && !password_salt.empty?
      self.password = hash(self.password)
    end
    
    # check if a plain text password matches the hashed, salted password
    def passwords_match?(password)
      self.password == hash(password) ? self : nil
    end
    
    # create and set a new password for this user, returning the new plain text password
    def reset_password
      self.password = ''
      PASS_LENGTH.times {self.password += SALT_ALPHABET.sample.chr}
      self.password.tap {self.save}
    end

    private
      def hash(password)
        Digest::SHA1.hexdigest("#{password_salt}:#{password}")
      end
  end
end
