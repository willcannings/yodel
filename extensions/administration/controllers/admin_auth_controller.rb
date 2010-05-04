module Yodel
  class AdminAuthController < AdminTreeController
    handles  Yodel::Group
    tab_name 'Security'
  end
end
