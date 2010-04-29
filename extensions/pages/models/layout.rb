module Yodel
  class Layout < Hierarchical
    creatable
    key :name, String, required: true
    key :content, HTML, required: true
    key :cacheable, Boolean
    key :dependencies, Array
    
    def cache
    end
    
    def invalidate_cache
    end
  end
end
