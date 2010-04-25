module Yodel
  class Application < Rack::Builder
    def initialize
      super
      use Rack::Reloader, 0
      use Rack::ContentLength
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
      controller_constant, action, match = Yodel.routes.match_request(request)
      
      if controller_constant
        controller = controller_constant.new(request, response, match)
        controller.send(action)
        response.finish
      else
        [404, {"Content-Type" => "text/plain"}, ["Not Found: #{request.path}"]]
      end
    end
  end
  
  class DefaultController < Controller
    route "/"

    def index
      response.write "Hello World!"
    end
  end
  
  class VersionController < Controller
    route "/version"
    before_filter :say_hello

    def index
      response.write "1.0"
    end
    
    def say_hello
      puts "helooooooooooooooooooooo"
    end
  end
end
