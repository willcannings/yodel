module Yodel
  class Config
    def initialize
      @options = {}
    end
    
    def method_missing(method, *args)
      method = method.to_s
      if method[-1] == '='
        @options[method[0...-1]] = args[0]
      elsif method[-1] == '?'
        @options.has_key?(method[0...-1])
      else
        @options[method]
      end
    end
  end
  
  def self.config
    @config ||= Config.new
  end
end
