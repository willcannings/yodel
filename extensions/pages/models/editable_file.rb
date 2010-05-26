module Yodel
  class EditableFile < Record
    key :name, String, required: true, index: true
    sort_by :name

    def icon
      '/admin/images/editable_file_icon.png'
    end
    
    # editable files are saved to disk for performance, and to make editing
    # files during development easier. the on disk version of each file takes
    # precedence to anything in the DB, so when deploying an app ensure the
    # public dir is deployed as well
    def file_path
      @file_path ||= Yodel.config.public_directory.join(self.site.identifier, name)
    end
    
    after_save :save_to_disk
    def save_to_disk
      File.open(file_path, 'w') do |file|
        file.write content
      end
    end
    
    after_destroy :remove_from_disk
    def remove_from_disk
      FileUtils.rm file_path if File.exist?(file_path)
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
