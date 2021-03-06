# FIXME: needs to be loaded on a site by site basis
require File.join(File.dirname(__FILE__), 'controllers', 'pages_controller')
require File.join(File.dirname(__FILE__), 'controllers', 'page_controller')
require File.join(File.dirname(__FILE__), 'models', 'layout')
require File.join(File.dirname(__FILE__), 'models', 'page')

require File.join(File.dirname(__FILE__), 'models', 'editable_file')
require File.join(File.dirname(__FILE__), 'models', 'upload_file')
require File.join(File.dirname(__FILE__), 'controllers', 'editable_file_controller')

require File.join(File.dirname(__FILE__), 'controllers', 'admin_layouts_controller')
require File.join(File.dirname(__FILE__), 'controllers', 'admin_design_controller')
require File.join(File.dirname(__FILE__), 'controllers', 'admin_page_controller')
