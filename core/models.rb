# in development mode, when files are refreshed, we need to unload all models
# before reloading otherwise they complain about duplicate keys & associations
if Module.const_defined?('Yodel')
  # TODO: destroy model objects during a refresh
  # if Yodel.const_defined?('Attachment')
  # if Yodel.const_defined?('Record')
  # if Yodel.const_defined?('Site')
end

require File.join(File.dirname(__FILE__), 'models', 'searchable')
require File.join(File.dirname(__FILE__), 'models', 'attachment')
require File.join(File.dirname(__FILE__), 'models', 'record')
require File.join(File.dirname(__FILE__), 'models', 'site')
require File.join(File.dirname(__FILE__), 'models', 'hierarchical')
