module Yodel
  class Layout < Hierarchical
    allowed_child_types self
    multiple_roots
    creatable
    
    key :name, String, required: true
    key :content, HTMLCode, required: true
    key :cacheable, Boolean
    key :dependencies, Array, display: false
    
    def cache
    end
    
    def invalidate_cache
    end


    # layouts are saved to disk to make editing during development easier.
    # the on disk version of each file takes precedence to anything in the
    # DB, so when deploying an app ensure the public dir is deployed as well
    def file_path(was=false)
      if was
        self.site.directory_path.join("#{self.name_was}.html")
      else
        self.site.directory_path.join("#{name}.html")
      end
    end
    
    after_save :save_to_disk
    def save_to_disk
      FileUtils.mkpath self.site.directory_path
      File.open(file_path, 'w') do |file|
        file.write content
      end
    end
    
    after_destroy :remove_from_disk
    before_save :remove_from_disk
    def remove_from_disk
      path = file_path(self.name_changed?)
      FileUtils.rm path if File.exist?(path)
    end
    
    def render_with_controller(controller)
      context = RenderContext.new(controller, {})
      context.set_value('content', controller.render_file(self.file_path, context))
      
      layout = self.parent
      until layout.nil?
        context.set_value('content', controller.render_file(layout.file_path, context))
        layout = layout.parent
      end
      context.get_value('content')
    end
  end
end
