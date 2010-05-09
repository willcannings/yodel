module Yodel
  class AdminListController < AdminController
    
    def index
      @content = render_file(File.join(File.dirname(__FILE__), '..', 'views', 'list.html.erb'))
      json list: @content
      super
    end
    
  end
end
