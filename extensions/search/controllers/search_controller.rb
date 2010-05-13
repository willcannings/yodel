module Yodel
  class SearchController < PageController
    def show
      # perform an 'or' search by default
      if params['query'].nil?
        @results = []
      else
        results = Set.new
        params['query'].search_terms_set.each do |term|
          Yodel::Record.all(yodel_search_keywords: term).each do |record|
            results << record
          end
        end
        @results = results.to_a.select {|record| record.show_in_search?}
      end
      
      super
    end
  end
end
