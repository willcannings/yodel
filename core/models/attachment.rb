# TODO: work out a way of refactoring where files are stored in to the site model
# already have directory_path method in there; need to use it somehow here (can't
# because the methods here rely on 'abstract_path' which is relative to the root
# dir, and not the actual path to the app which is what directory_path is)

module Yodel
  class Attachment
    include ::MongoMapper::EmbeddedDocument
    key :attachment_name, String, required: true
    key :file_name, String, required: true
    key :mime_type, String, required: true
    embedded_in :record
    
    def url
      @url ||= Pathname.new('/').join(relative_path)
    end
    
    def relative_path
      @relative_path ||= File.join(relative_directory_path, self.file_name)
    end
    
    def relative_directory_path
      @relative_directory_path ||= File.join(record.site.identifier, Yodel.config.attachment_directory_name, self.attachment_name, self.id.to_s)
    end
    
    def path
      @path ||= Yodel.config.public_directory.join(relative_path)
    end
    
    def directory_path
      @directory_path ||= Yodel.config.public_directory.join(relative_directory_path)
    end
    
    def reset_memoised_values
      @url = @relative_path = @relative_directory_path = @path = @directory_path = nil
    end
    
    def exist?
      File.exist?(path)
    end
    
    before_destroy :remove_files
    def remove_files
      FileUtils.rmdir directory_path if exist?
    end
    
    def set_file(file)
      # delete the old file and reset memoised paths
      unless new?
        remove_files
        reset_memoised_values
      end

      # reset the name and mime type of the attachment
      self.file_name = file[:filename]
      self.mime_type = file[:type]
      temp = file[:tempfile]
      temp_path = temp.path
      temp.close
      
      # for simplicity we move the uploaded file (from /tmp) rather than copying
      FileUtils.mkpath directory_path
      FileUtils.mv(temp_path, path)
      FileUtils.chmod(0664, path)
    end
    
    def length
      return 0 unless self.exist?
      return File.size(path)
    end
  end
  
  class ImageAttachment < Attachment
    def set_file(file)
      super(file)
      crop_image
    end
    
    def crop_image
      sizes = record.associations[attachment_name].options[:sizes]
      return if sizes.nil? || sizes.empty? || !exist?
      ImageScience.with_image(path.to_s) do |img|
        iw, ih = img.width, img.height
        sizes.each do |name, size|
          sw, sh = size.split('x').collect(&:to_i)
          aspect = sw.to_f / sh.to_f
          w, h = (ih * aspect), (iw / aspect)
          w = [iw, w].min.to_i
          h = [ih, h].min.to_i
          img.with_crop((iw-w)/2, (ih-h)/2, (iw+w)/2, (ih+h)/2) do |crop|
            crop.resize(sw, sh) do |resized|
              resized.save resized_image_path(name, false).to_s
            end
          end
        end
      end
    end
    
    # TODO: shouldn't always be .jpg; have image extension as an option
    def resized_image_path(name, crop_if_required=true)
      path = Yodel.config.public_directory.join(relative_directory_path, "#{name}.jpg")
      crop_image unless path.exist? || !crop_if_required
      path
    end
    
    # TODO: relative path from is quite a complex method; we should optimise the whole path system here somehow
    def relative_resized_image_path(name)
      resized_image_path(name).relative_path_from(Yodel.config.public_directory)
    end
    
    def resized_image_url(name)
       Pathname.new('/').join(relative_resized_image_path(name))
    end
    
    def method_missing(name, *args)
      unless name.to_s.end_with?('_url')
        super(name, args)
      else
        resized_image_url(name.to_s.sub('_url', ''))
      end
    end
  end
  
  class UniqueAttachment < Attachment
    def relative_directory_path
      @relative_directory_path ||= File.join(record.site.identifier)
    end
    
    def remove_files
      FileUtils.rm path if exist?
    end
  end
end
