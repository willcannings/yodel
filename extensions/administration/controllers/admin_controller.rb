module Yodel
  class AdminController < Controller
    include Yodel::AdminControllerHelper
    include Yodel::AdminFormHelper
    before_filter :admin_required
    
    def index
      html do
        render_file File.join(File.dirname(__FILE__), '..', 'views', 'admin.html.erb')
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
    
    def tab_name
      self.class.tab_name
    end
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@handles', @handles)
      # FIXME: need better way of excluding these special subclasses...
      Yodel.config.admin_tabs << child unless child.name == 'Yodel::AdminListController' || child.name == 'Yodel::AdminTreeController'
    end
    
    # the models this admin controller is responsible for
    def self.handles(*models)
      @handles = models
      self.controller_models.each do |model|
        eval "class Yodel::Admin#{model.name.demodulize.camelcase}ModelController < Yodel::AdminModelController
                admin_controller #{self.name}
                handles #{model.name}
              end"
      end
    end
  end
end
