module Yodel
  class UploadFile < Record
    creatable
    key :name, String, required: true, index: true
    attachment :upload
    
    def icon
      '/pages_static/images/upload_file_icon.png'
    end
  end
end
