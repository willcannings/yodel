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
    
    def render_with_controller(controller)
      context = RenderContext.new(controller, {})
      context.set_value('content', controller.render_string(self.content, context))
      
      layout = self.parent
      until layout.nil?
        context.set_value('content', controller.render_string(layout.content, context))
        layout = layout.parent
      end
      context.get_value('content')
    end
  end
end
