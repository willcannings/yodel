module Yodel
  module Searchable
    
    def searchable
      class_eval do
        # yodel_search_keywords is a list of keywords (strings) which will match this record
        # by default split all string keys (with !searchable false) and remove all non word
        # characters. sub-classes should override this method if different functionality req.
        key :yodel_search_keywords, Array, index: true, display: false
    
        before_save :update_search_keywords
        def update_search_keywords
          # TODO: update search keywords default impl
        end
      end
    end
    
  end
end
