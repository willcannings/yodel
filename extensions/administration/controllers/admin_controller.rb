module Yodel
  class AdminController < Controller
    include Yodel::AdminControllerHelper
    include Yodel::AdminFormHelper
    before_filter :admin_required
    
    def index
      html do
        render_file File.join(File.dirname(__FILE__), '..', 'views', 'admin.html')
      end
    end
    
    def self.tab_name(name=nil)
      if name
        @tab_name = name
        route "/admin/#{name.underscore}/"
      else
        @tab_name
      end
    end
    
    # FIXME: need better way of excluding these special subclasses...
    def self.inherited(child)
      super(child)
      Yodel.config.admin_tabs << child unless child.name == 'Yodel::AdminListController' || child.name == 'Yodel::AdminTreeController'
    end
    
    def self.handles(*models)
      @handles = models
      models.each do |model|
        eval "
          class Admin#{model.name.split("::")[-1].camelcase}ModelController < AdminModelController
            handles #{model.name}
          end
        "
      end
    end
  end
end
