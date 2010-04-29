module Yodel
  class Attachment
    include ::MongoMapper::EmbeddedDocument
    belongs_to :record
    key :file_name, String, required: true
    key :mime_type, String, required: true
    
    def url
      Pathname.new('/').join(Yodel.config.public_directory_name, record.site.identifier, id, file_name)
    end
    
    def path
      Yodel.config.public_directory.join(record.site.identifier, id, file_name)
    end
    
    before_destroy :remove_file
    def remove_file
      FileUtils.rm(path)
    end
  end
  
  class ImageAttachment < Attachment
  end
end
