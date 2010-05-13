# this file will typically be 'require'd by a config.ru file in an
# app's root directory (loading rack in the process), but to make
# requiring yodel simple, we require it here as well, so
# require 'yodel' will work with no problems.
require 'active_support/memoizable'
require 'active_support/core_ext'
require 'image_science'
require 'mongo_mapper'
require 'pathname'
require 'hpricot'
require 'ostruct'
require 'builder'
require 'erubis'
require 'json'
require 'rack'
require 'rack/contrib'

# start app configuration
require File.join(File.dirname(__FILE__), 'core', 'config')

# initialise MongoMapper
# FIXME: need port here as well
if Yodel.config.database_hostname?
  MongoMapper.connection = Mongo::Connection.new(Yodel.config.database_hostname)
end
MongoMapper.database = Yodel.config.database || "Yodel"

# assign default values if needed
Yodel.config.session_secret             ||= "yodel.session"
Yodel.config.public_directory_name      ||= "public"
Yodel.config.attachment_directory_name  ||= "attachments"

# determine root directories
Yodel.config.yodel_root = Pathname.new(File.dirname(__FILE__))
Yodel.config.root = Yodel.config.yodel_root.join('..')
Yodel.config.public_directory = Yodel.config.root.join(Yodel.config.public_directory_name)

# initialise Yodel
require File.join(File.dirname(__FILE__), 'core', 'flash')
require File.join(File.dirname(__FILE__), 'core', 'mime_types')
require File.join(File.dirname(__FILE__), 'core', 'middleware')
require File.join(File.dirname(__FILE__), 'core', 'routes')
require File.join(File.dirname(__FILE__), 'core', 'controllers')
require File.join(File.dirname(__FILE__), 'core', 'types')
require File.join(File.dirname(__FILE__), 'core', 'models')
require File.join(File.dirname(__FILE__), 'core', 'extensions')

# by default, attachments are served from the public folder in the root of the app
Yodel.use_middleware do |app|
  app.use Yodel::ConditionalFile, Yodel.config.public_directory
end

# load yodel and app extensions
Yodel.load_extensions(Yodel.config.yodel_root.join('extensions'))
Yodel.load_extensions(Yodel.config.root.join('extensions'))
Yodel.load_extensions(Yodel.config.root.join('app'))

# FIXME: hack!!!
ObjectSpace.each_object do |obj|
  if obj.respond_to?(:ancestors) && obj.ancestors.include?(Yodel::AdminController)
    obj.generate_admin_model_controllers
  end
end

# finally load and start the yodel application
Dir.chdir(Yodel.config.root)
require File.join(File.dirname(__FILE__), 'core', 'yodel_application')
