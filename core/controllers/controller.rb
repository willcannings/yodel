module Yodel
  class Controller
    def initialize(request, response, match, site)
      @request, @response, @match, @site = request, response, match, site
      @env = request.env
      
      # run before filters
      self.class.before_filters.each {|method| self.send(method)}
    end
    
    def env
      @env
    end
    
    def request
      @request
    end
    
    def response
      @response
    end
    
    def match
      @match
    end
    
    def site
      @site
    end
    
    def session
      @env['rack.session']
    end
    
    def self.route(path, options = nil)
      Yodel.routes << {controller: self, method: :any, action: :index, path: path}.merge(options || {})
    end
    
    # before filters are run before the controller performs an action
    def self.before_filters
      @before_filters ||= []
    end
    
    def self.before_filter(method)
      before_filters << method
    end
    
    def self.inherited(child)
      child.instance_variable_set('@before_filters', @before_filters)
    end
  end
end
