module Yodel
  class Layout < Hierarchical
    multiple_roots
    creatable
    default_child_type  self
    allowed_child_types self
    
    key :name, String, required: true
    key :content, HTMLCode, required: true
    key :cacheable, Boolean
    key :dependencies, Array, display: false
    
    def cache
    end
    
    def invalidate_cache
    end
    
    def render_with_controller(controller)
      layout = self.parent
      page_content = controller.render_string(self.content)
      until layout.nil?
        page_content = controller.render_string(layout.content, content: page_content)
        layout = layout.parent
      end
      page_content
    end
  end
end
