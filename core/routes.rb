module Yodel
  class RouteSet
    def initialize
      @routes = []
      @sorted = false
    end
    
    def <<(route)
      @routes << Route.new(route)
    end
    
    def sort_routes!
      @routes = @routes.sort_by {|path, method, controller, action| -path.to_s.length}
      @sorted = true
    end
    
    def match_request(request)
      sort_routes! unless @sorted
      request_method = request.request_method.downcase.to_sym
      path = request.path_info
      
      @routes.each do |route|
        match = route.match(path, request_method)
        return [route.controller, route.action, match] unless match.nil?
      end
      
      [nil, nil, nil]
    end
    
    def path_for(controller, action, options)
      @routes.each do |route|
        return route.path_with_options(options) if route.controller == controller && route.action == action
      end
      nil
    end
  end
  
  class Route
    attr_accessor :method, :original_path, :path, :controller, :action
    def initialize(route)
      @method = route[:method].to_s.downcase.to_sym
      @original_path = route[:path]
      @path = Regexp.new("^#{Regexp.quote(route[:path].chomp('/')).gsub('/', '/+')}(?<format>\\.\\w+)?(?<glob>.*)", nil, 'n') # from Rack::URLMap
      @controller = route[:controller]
      @action = route[:action]
    end
    
    def match(path, request_method)
      return nil unless @method == :any || @method == request_method
      @path.match(path)
    end
    
    def path_with_options(options={})
      path = @original_path.dup
      options.each do |name, value|
        path.gsub!(/\(\?\<#{name}\>.+\)/, value.to_s)
      end
      path
    end
  end
  
  def self.routes
    @routes ||= RouteSet.new
  end
end
