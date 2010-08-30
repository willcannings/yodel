module Yodel
  class Controller
    def initialize(request, response, site)
      @request, @response, @site = request, response, site
      @env = request.env
    end
    
    def self.handle_request(request, response, site, action)
      controller = self.new(request, response, site)
      controller.handle_request_with_action(action)
    end
    
    def handle_request_with_action(action)
      run_before_filters(action)
      send(action)
      run_after_filters(action)
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
    # TODO: possible cleanup: why have extra context and context object; just force callers to construct a context object anyway?
    def render_file(file, context=nil, extra_context={})
      File.open(file, 'r') do |file|
        render_string file.read, context, extra_context
      end
    end
    
    def render_string(markup, context=nil, extra_context={})
      if context.nil?
        context = RenderContext.new(self, extra_context)
      end
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
        mime_type = Yodel.mime_types.type(name)
        raise "Unknown Mime Type: #{name}" if mime_type.nil?
        @responses[name] = block
      elsif args.length >= 1
        @responses[name] = args.first
      else
        @responses[name] = ''
      end
    end
    
    after_filter :write_response
    def write_response
      return unless response.empty?
      return if @responses.nil?
      
      @responses.each do |name, data|
        mime_type = Yodel.mime_types.type(name)
        if mime_type.try(:matches_request?, request) # FIXME: why are we using try here? document or change
          data = data.call(mime_type.create_builder) if data.is_a? Proc 
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
