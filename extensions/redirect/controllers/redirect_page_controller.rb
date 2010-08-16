module Yodel
  class RedirectPageController < Yodel::PageController
    def show
      unless @page.url.nil? || @page.url.blank?
        response.redirect @page.url
      else
        response.redirect '/'
      end
    end
  end
end
