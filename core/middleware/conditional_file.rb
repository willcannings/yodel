module Yodel
  # serves a file if the path exists; otherwise passes control to the next app
  class ConditionalFile < Rack::File
    def initialize(app, root)
      super(root)
      @app = app
    end
    
    def _call(env)
      @env = env
      super(env)
    end
    
    def not_found
      @app.call(@env)
    end
  end
end
