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
          search_terms = Set.new
          self.class.keys.values.each do |key|
            next if key.name.starts_with?('_') || key.options[:searchable] == false || key.type.nil? || !key.type.instance_methods.include?(:search_terms_set)
            (self.send(key.name) || '').search_terms_set.each do |term|
              search_terms << term.downcase
            end
          end
          self.yodel_search_keywords = search_terms.to_a
        end
      end
      
      # by default records which include this module can be displayed in search results
      def show_in_search?
        true
      end
      
      # needs to be overriden
      def search_title
        ''
      end
    end
    
  end
end
