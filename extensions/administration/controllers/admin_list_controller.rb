module Yodel
  class AdminListController < AdminController
    
    def index
      if session['selected']
        @selected_record = Yodel::Record.find(session['selected'])
        session.delete('selected')
      end
      
      @content = render_file(File.join(File.dirname(__FILE__), '..', 'views', 'list.html.erb'))
      json list: @content
      super
    end
    
  end
end
