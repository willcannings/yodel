Yodel.config.admin_tabs = []

require File.join(File.dirname(__FILE__), 'models', 'record')
require File.join(File.dirname(__FILE__), 'models', 'user')
require File.join(File.dirname(__FILE__), 'models', 'group')
require File.join(File.dirname(__FILE__), 'helpers', 'admin_form_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'admin_controller_helper')
require File.join(File.dirname(__FILE__), 'controllers', 'admin_controller')
require File.join(File.dirname(__FILE__), 'controllers', 'admin_model_controller')
require File.join(File.dirname(__FILE__), 'controllers', 'admin_list_controller')
require File.join(File.dirname(__FILE__), 'controllers', 'admin_tree_controller')
require File.join(File.dirname(__FILE__), 'controllers', 'admin_auth_controller')

Yodel.use_middleware do |app|
  app.use Rack::Static, :urls => ["/admin_static"], :root => File.dirname(__FILE__)
end
