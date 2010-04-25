module Yodel
  class RouteSet
    def initialize
      @routes = []
      @sorted = false
    end
    
    def <<(route)
      method = route[:method].to_s.downcase.to_sym
      path = Regexp.new("^#{Regexp.quote(route[:path].chomp('/')).gsub('/', '/+')}(.*)", nil, 'n') # from Rack::URLMap
      @routes << [path, method, route[:controller], route[:action]]
    end
    
    def sort_routes!
      @routes = @routes.sort_by {|path, method, controller, action| -path.to_s.length}
      @sorted = true
    end
    
    def match_request(request)
      sort_routes! unless @sorted
      request_method = request.request_method.downcase.to_sym
      
      @routes.each do |path, method, controller, action|
        next unless method == :any || method == request_method
        next unless match = path.match(request.path_info)
        return [controller, action, match]
      end
      
      [nil, nil, nil]
    end
  end
  
  @@routes = RouteSet.new
  def self.routes
    @@routes
  end
end
