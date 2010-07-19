module Yodel
  class SearchController < PageController
    def show
      tags = params['query'].to_s.split(' ').reject(&:blank?)
      @results = Yodel::Record.all(yodel_search_keywords: tags).to_a.select(&:show_in_search?)
      super
    end
  end
end
