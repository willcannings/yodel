module Yodel
  class Controller
    def initialize(request, response, match, site)
      @request, @response, @match, @site = request, response, match, site
      @env = request.env
      
      # merge the named captures from match (such as 'id') with params
      match.names.each do |capture_name|
        @request.params[capture_name] = match[capture_name]
      end
    end
    
    # basic environment accessors
    def env
      @env
    end
    
    def request
      @request
    end
    
    def params
      @request.params
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
      @env['rack.session'] ||= {}
    end
    
    
    # before filters are run before the controller performs an action
    # after filters are run after the action has finished running
    def self.before_filters
      @before_filters ||= []
    end
    
    def self.after_filters
      @after_filters ||= []
    end
    
    def self.before_filter(method, options={})
      before_filters << [method, options]
    end
    
    def self.after_filter(method, options={})
      after_filters << [method, options]
    end
    
    def self.run_before_filters(context, action)
      before_filters.each do |method, options|
        if !options.empty?
          next if options[:only] && ![*options[:only]].include?(action)
          next if options[:except] && [*options[:except]].include?(action)
        end
        context.send(method)
      end
    end
    
    def run_before_filters(action)
      self.class.run_before_filters(self, action)
    end
    
    def self.run_after_filters(context, action)
      after_filters.each do |method, options|
        if !options.empty?
          next if options[:only] && ![*options[:only]].include?(action)
          next if options[:except] && [*options[:except]].include?(action)
        end
        context.send(method)
      end
    end
    
    def run_after_filters(action)
      self.class.run_after_filters(self, action)
    end
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@before_filters', @before_filters)
      child.instance_variable_set('@after_filters', @after_filters)
    end
    
    
    # rendering
    def render_file(file, extra_context={})
      File.open(file, 'r') do |file|
        render_string file.read, extra_context
      end
    end
    
    def render_string(markup, extra_context={})
      context = RenderContext.new(self, extra_context)
      Erubis::Eruby.new(markup).evaluate(context)
    end
    
    
    # controller routes
    # FIXME: needs to take a site parameter
    def self.route(path, options={})
      Yodel.routes << {controller: self, method: :any, action: :index, path: path}.merge(options)
    end
    
    def self.path_and_action_for(action, options={})
      Yodel.routes.path_and_action_for(self, action, options)
    end
    
    
    # content and status code assignment
    def status(code)
      response.status = code
    end
    
    # TODO: sanity check that name is a valid mime type
    def method_missing(name, *args, &block)
      @responses ||= {}
      
      if block_given?
        @responses[name] = yield
      elsif args.length >= 1
        @responses[name] = args.first
      else
        @responses[name] = ''
      end
    end
    
    after_filter :write_response
    def write_response
      return unless response.empty?
      
      @responses.each do |name, data|
        mime_type = Yodel.mime_types.type(name)
        if mime_type.try(:matches_request?, request) # FIXME: why are we using try here? document or change
          response.write mime_type.process(data)
          response['Content-Type'] = mime_type.default_mime_type
          return
        end
      end
      
      # no response matches the request, so respond with
      # the first response data we have
      # FIXME: should loop here for the first mime_type that matches in case keys.first isn't a valid mime type
      type = @responses.keys.first
      mime_type = Yodel.mime_types.type(type)
      response['Content-Type'] = mime_type.default_mime_type
      response.write mime_type.process(@responses[type])
    end
  end
end
