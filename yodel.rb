# this file will typically be 'require'd by a config.ru file in an
# app's root directory (loading rack in the process), but to make
# requiring yodel simple, we require it here as well, so
# require 'yodel' will work with no problems.
require 'active_support/memoizable'
require 'active_support/core_ext'
require 'image_science'
require 'mongo_mapper'
require 'bigdecimal'
require 'pathname'
require 'hpricot'
require 'ostruct'
require 'builder'
require 'logger'
require 'erubis'
require 'json'
require 'rack'
require 'rack/contrib'

# Yodel
require File.join(File.dirname(__FILE__), 'core', 'config')
require File.join(File.dirname(__FILE__), 'core', 'yodel_application')
Yodel.config.logger = Logger.new('yodel.log')
Yodel.config.sev_threshold = Logger::DEBUG
