require File.join(File.dirname(__FILE__), 'models', 'editable_file')
require File.join(File.dirname(__FILE__), 'models', 'upload_file')
require File.join(File.dirname(__FILE__), 'models', 'layout')
require File.join(File.dirname(__FILE__), 'models', 'layout')
require File.join(File.dirname(__FILE__), 'models', 'page')

Yodel.use_middleware do |app|
  app.use Rack::Static, :urls => ["/static"], :root => Yodel.config.public_directory
end
