module Yodel
  class UploadFile < Record
    creatable
    unique_attachment :upload
    
    def name
      self.upload.file_name
    end
    
    def icon
      '/pages_static/images/upload_file_icon.png'
    end
  end
end
