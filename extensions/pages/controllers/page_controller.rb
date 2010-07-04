module Yodel
  class PageController < Controller
    def show
      @content = @page.content
      html @page.layout.render_with_controller(self)
      json :content => @page.content, :title => @page.title
    end
  end
end
