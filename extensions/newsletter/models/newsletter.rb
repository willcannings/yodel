module Yodel
  class Newsletter < Record
    belongs_to :layout, display: true, required: true
    key :subject, String, required: true
    key :from, String, required: true
    key :content, HTML
    key :text_content, Text
  end
end
