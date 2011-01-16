module Yodel
  class Flash
    def initialize(session)
      @session = session
      @last_request = @session['flash'] || {}
      @this_request = {}
    end
    
    def finalize
      @session['flash'] = @this_request
    end
    
    def [](key)
      if @this_request.key?(key)
        @this_request[key]
      elsif @last_request.key?(key)
        @last_request[key]
      else
        nil
      end
    end
    
    def []=(key, value)
      @this_request[key] = value
    end
    
    def delete(key)
      @this_request.delete(key)
      @last_request.delete(key)
    end
  end
end
