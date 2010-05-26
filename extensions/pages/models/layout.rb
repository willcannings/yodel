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
    def file_path
      @file_path ||= Yodel.config.public_directory.join(self.site.identifier, "#{name}.html")
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
