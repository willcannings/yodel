module Yodel
  class AdminController < Controller
    include Yodel::AdminControllerHelper
    before_filter :admin_required
    
    def self.tab_name(name=nil)
      if name
        @tab_name = name
        route "/admin/#{name.underscore}/"
      else
        @tab_name
      end
    end
    
    def self.inherited(child)
      super(child)
      # FIXME: need better way of doing this...
      Yodel.config.admin_tabs << child unless child.name == 'Yodel::AdminListController' || child.name == 'Yodel::AdminTreeController'
    end
    
    def self.handles(*models)
    end
  end
end
