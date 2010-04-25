# initialise Yodel
require File.join(File.dirname(__FILE__), 'core', 'config')
require File.join(File.dirname(__FILE__), 'core', 'routes')
require File.join(File.dirname(__FILE__), 'core', 'controllers')
require File.join(File.dirname(__FILE__), 'core', 'models')
require File.join(File.dirname(__FILE__), 'core', 'yodel_application')

# initialise MongoMapper
require 'mongo_mapper'
if Yodel.config.database_hostname?
  MongoMapper.connection = Mongo::Connection.new(Yodel.config.database_hostname)
end
if !Yodel.config.database?
  Yodel.config.database = "Yodel"
end
MongoMapper.database = Yodel.config.database
