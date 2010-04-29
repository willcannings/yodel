module Yodel
  class UpoadFile < Record
    creatable
    key :name, String, required: true, index: true
    attachment :upload
  end
end
