module Yodel
  class Layout < Hierarchical
    multiple_roots
    creatable
    default_child_type  self
    allowed_child_types self
    
    key :name, String, required: true
    key :content, HTML, required: true
    key :cacheable, Boolean
    key :dependencies, Array, display: false
    
    def cache
    end
    
    def invalidate_cache
    end
  end
end
