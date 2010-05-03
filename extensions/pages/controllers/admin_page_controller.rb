module Yodel
  class AdminPageController < AdminTreeController
    handles  Yodel::Page
    tab_name 'Pages'
    before_filter :print_env
    def print_env
      p request
    end
    
    
    def index
      html "hello world!"
      json records: []
    end
  end
end
