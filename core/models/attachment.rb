module Yodel
  class Attachment
    include ::MongoMapper::EmbeddedDocument
    key :attachment_name, String, required: true
    key :file_name, String, required: true
    key :mime_type, String, required: true
    embedded_in :record
    
    def url
      @url ||= Pathname.new('/').join(Yodel.config.public_directory_name, relative_path)
    end
    
    def path
      @path ||= Yodel.config.public_directory.join(relative_path)
    end
    
    def relative_path
      @relative_path ||= File.join(relative_directory_path, file_name)
    end
    
    def relative_directory_path
      @relative_directory_path ||= File.join(record.site.identifier, attachment_name, id.to_s)
    end
    
    def directory_path
      @directory_path ||= Yodel.config.public_directory.join(relative_directory_path)
    end
    
    def exist?
      File.exist?(path)
    end
    
    before_destroy :remove_files
    def remove_files
      FileUtils.rmdir directory_path
    end
    
    def set_file(file)
      self.file_name = file[:filename]
      self.mime_type = file[:type]
      temp = file[:tempfile]
      temp_path = temp.path
      temp.close
      
      remove_files if exist?
      FileUtils.mkpath directory_path
      FileUtils.mv(temp_path, path)
    end
  end
  
  class ImageAttachment < Attachment
    def set_file(file)
      super(file)
      
      # crop to the required sizes
      #record.associations
    end
  end
  
  class UniqueAttachment < Attachment
    def relative_directory_path
      @relative_directory_path ||= File.join(record.site.identifier, attachment_name)
    end
  end
end
