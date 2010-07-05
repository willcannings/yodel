module Yodel
  class Snippet < Record
    creatable
    key :name, String, required: true, index: true
    key :content, Text, required: true
  end
end
