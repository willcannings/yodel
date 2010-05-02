# because of the circular reference between groups and users, we can't
# define the models in separate classes

module Yodel
  class User < Record
    creatable
    belongs_to :group
    
    key :username, String, required: true, index: true
    key :password, String, required: true, index: true
  end
  
  class Group < Hierarchical
    creatable
    has_many :users, dependent: :destroy, class: Yodel::User
    key :name, String, required: true
  end
end
