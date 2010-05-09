module Yodel
  class AdminLayoutsController < AdminTreeController
    handles  Yodel::Layout
    tab_name 'Layouts'
  end
end
