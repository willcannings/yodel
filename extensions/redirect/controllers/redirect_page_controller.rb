module Yodel
  class RedirectPageController < Yodel::PageController
    def show
      response.redirect @page.url
    end
  end
end
