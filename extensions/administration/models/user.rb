module Yodel
  class User < Hierarchical
    cannot_be_root
    creatable
    key :username, String, required: true, index: true
    key :password, String, required: true
    
    default_child_type  nil
    allowed_child_types nil
  end
end
