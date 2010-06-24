module Yodel
  class Application < Rack::Builder
    def initialize
      super
      boot
      
      use Rack::Reloader, 0
      use Rack::ContentLength
      use Rack::NestedParams
      use Rack::Sendfile
      use Rack::Session::Cookie, key: 'yodel.session', secret: Yodel.config.session_secret
      Yodel.initialise_middleware_with_app(self)
      run Yodel::RequestHandler.new
      @app = to_app
    end

    # TODO: extract boot out to "components" with dependencies; automatically resolve boot order based on deps
    def boot
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
      Yodel.config.yodel_root = Pathname.new(File.dirname(__FILE__)).join('..')
      Yodel.config.root = Yodel.config.yodel_root.join('..')
      Yodel.config.public_directory = Yodel.config.root.join(Yodel.config.public_directory_name)

      # load Yodel components
      require File.join(File.dirname(__FILE__), 'flash')
      require File.join(File.dirname(__FILE__), 'mime_types')
      require File.join(File.dirname(__FILE__), 'middleware')
      require File.join(File.dirname(__FILE__), 'routes')
      require File.join(File.dirname(__FILE__), 'controllers')
      require File.join(File.dirname(__FILE__), 'types')
      require File.join(File.dirname(__FILE__), 'models')
      require File.join(File.dirname(__FILE__), 'extensions')
      
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

      # deterministic PWD regardless of where we're require'd from
      Dir.chdir(Yodel.config.root)
    end
    
    def call(env)
      @app.call(env)
    end
  end
  
  class RequestHandler
    def call(env)
      start = Time.now
      request  = Rack::Request.new(env)
      response = Rack::Response.new
      site = Site.find_by_domain(request.host)
      controller, action, match = Yodel.routes.match_request(request)
      
      unless controller.nil? || site.nil?
        controller.handle_request(request, response, site, action)
        finish = Time.now
        Yodel.config.logger.info "Request: #{request.url}; handling by #{controller.name} (#{finish.to_f - start.to_f})"
        response.finish
      else
        finish = Time.now
        Yodel.config.logger.info "Request: #{request.url}; 404 (#{finish.to_f - start.to_f})"
        [404, {"Content-Type" => "text/plain"}, ["URL Not Found: #{request.path}"]]
      end
    end
  end
end
