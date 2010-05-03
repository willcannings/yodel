module Yodel
  class AdminModelController < ModelController
    include Yodel::AdminControllerHelper
    before_filter :admin_required
    route_prefix  'admin_records'
  end
end
