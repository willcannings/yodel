module Yodel
  class PageController < Controller
    def show
      @content = @page.content
      html @page.find_layout.render_with_controller(self)
    end
  end
end
