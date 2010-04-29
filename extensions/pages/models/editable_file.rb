module Yodel
  class EditableFile < Record
    key :name, String, required: true, index: true
    def path
    end
  end
  
  class JavascriptFile < EditableFile
    creatable
    key :content, Javascript, required: true
    def mime_type
      "text/javascript"
    end
  end
  
  class CSSFile < EditableFile
    creatable
    key :content, CSS, required: true
    def mime_type
      "text/css"
    end
  end
end
