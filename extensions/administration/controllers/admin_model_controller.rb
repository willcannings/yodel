module Yodel
  class AdminModelController < ModelController
    include Yodel::AdminControllerHelper
    before_filter :admin_required
    route_prefix  'admin_records'
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@admin_controller', @admin_controller)
    end
    
    def self.admin_controller(controller=nil)
      @admin_controller ||= controller
    end
    
    def create
      super
      redirect_to_admin_controller
    end
    
    def update
      super
      redirect_to_admin_controller
    end
    
    def destroy
      super
      @record = nil
      redirect_to_admin_controller
    end
    
    private
      def redirect_to_admin_controller
        # FIXME: dirty dirty hack
        session['selected'] = @record.id unless @record.nil?
        response.redirect self.class.admin_controller.path_and_action_for(:index).path
      end
  end
end
