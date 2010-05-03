module Yodel
  class AdminPageController < AdminTreeController
    handles  Yodel::Page
    tab_name 'Pages'
  end
end
