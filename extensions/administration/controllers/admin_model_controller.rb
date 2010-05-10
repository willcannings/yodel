module Yodel
  class AdminModelController < ModelController
    include Yodel::AdminControllerHelper
    before_filter :admin_required
    after_filter  :assign_errors_to_session
    after_filter  :redirect_to_admin_controller, except: [:index, :show]
    route_prefix  'admin_records'
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@admin_controller', @admin_controller)
    end
    
    def self.admin_controller(controller=nil)
      @admin_controller ||= controller
    end
    
    private
      def assign_errors_to_session
        return if @record.nil? || @record.errors.nil?
        session['errors'] = @record.errors.errors
      end
      
      def redirect_to_admin_controller
        # FIXME: dirty dirty hack; we really need to do more client side JS than this
        session['selected'] = @record.id unless @record.nil?
        response.redirect self.class.admin_controller.path_and_action_for(:index).path
      end      
  end
end
