module Yodel
  class Application < Rack::Builder
    def initialize
      super
      use Rack::Reloader, 0
      use Rack::ContentLength
      use Rack::NestedParams
      use Rack::Sendfile
      use Rack::Session::Cookie, key: 'yodel.session', secret: Yodel.config.session_secret
      Yodel.initialise_middleware_with_app(self)
      run Yodel::RequestHandler.new
      @app = to_app
    end
    
    def call(env)
      @app.call(env)
    end
  end
  
  class RequestHandler
    def call(env)
      request  = Rack::Request.new(env)
      response = Rack::Response.new
      site = Site.find_by_domain(request.host)
      controller, action, match = Yodel.routes.match_request(request)
      
      unless controller.nil? || site.nil?
        controller.handle_request(request, response, site, action)
        response.finish
      else
        [404, {"Content-Type" => "text/plain"}, ["URL Not Found: #{request.path}"]]
      end
    end
  end
end
