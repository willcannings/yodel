module Yodel
  class RedirectPage < Yodel::Page
    page_controller Yodel::RedirectPageController
    creatable
    
    key :content, HTML, display: false
    key :url, String
  end
end
