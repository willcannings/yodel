module Yodel
  # serves a file if the path exists; otherwise passes control to the next app
  class ConditionalFile < Rack::File
    def initialize(app, root, options={})
      super(root)
      @app = app
      @prefix = options.delete(:prefix)
    end
    
    def _call(env)
      @env = env

      unless @prefix.nil?
        @path_info = Rack::Utils.unescape(env["PATH_INFO"])
        return not_found unless @path_info.start_with?(@prefix)
        env["PATH_INFO"] = @path_info.sub(@prefix, '')
      end
      super(env)
    end
    
    def not_found
      @app.call(@env)
    end
    
    def fail(status, body)
      @app.call(@env)
    end
  end
end
