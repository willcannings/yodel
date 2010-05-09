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
    
    def tab_name
      self.class.tab_name
    end
    
    
    # FIXME: need better way of excluding these special subclasses...
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@handles', @handles)
      Yodel.config.admin_tabs << child unless child.name == 'Yodel::AdminListController' || child.name == 'Yodel::AdminTreeController'
    end
    
    
    # the models this admin controller is responsible for
    def self.handles(*models)
      @handles = models
      models.each do |model|
        eval "class Yodel::Admin#{model.name.demodulize.camelcase}ModelController < Yodel::AdminModelController
                handles #{model.name}
              end"
      end
    end
    
    def self.controller_models
      models = Set.new
      @handles.each do |model|
        models << model
        model.descendents.each {|child| models << child}
      end
      models.to_a.select {|model| model.creatable?}
    end
    
    def controller_models
      self.class.controller_models
    end
  end
end
