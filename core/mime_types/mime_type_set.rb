module Yodel
  class MimeTypeSet
    attr_accessor :types
    def initialize
      @types = {}
      @extensions = {}
      @mime_types = {}
    end
    
    def <<(type)
      @types[type.name] = type
      type.extensions.each {|extension| @extensions[extension] = type}
      type.mime_types.each {|mime_type| @mime_types[mime_type] = type}
    end
    
    def type(name)
      @types[name.to_sym]
    end
  end
  
  class MimeType
    attr_accessor :name, :extensions, :mime_types
    def initialize(name)
      @name = name
      @extensions = []
      @mime_types = []
      @transformer = nil
    end

    def mime_types(*types)
      @mime_types += types
    end
    
    def extensions(*exts)
      @extensions += exts
    end
    
    def default_extension(ext=nil)
      if ext.nil?
        @extensions[0]
      else
        @extensions.delete(ext)
        @extensions.insert(0, ext)
      end
    end
    
    def default_mime_type(type=nil)
      if type.nil?
        @mime_types[0]
      else
        @mime_types.delete(type)
        @mime_types.insert(0, type)
      end      
    end
    
    def default_extension=(ext)
      default_extension(ext)
    end
    
    def default_mime_type=(type)
      default_mime_type(type)
    end
    
    def builder(&block)
      @builder = block
    end
    
    def create_builder
      if @builder
        @builder.call
      else
        nil
      end
    end
    
    def transformer(&block)
      @transformer = block
    end
    
    def process(data)
      if @transformer
        @transformer.call(data)
      else
        data
      end
    end
        
    def matches_request?(request)
      # try format first, then fall back to accept header
      if request.params['format']
        @extensions.include?(request.params['format'])
      else
        return false if request.env['HTTP_ACCEPT'].blank?
        @mime_types.any? {|type| request.env['HTTP_ACCEPT'].include?(type)}
      end
    end
  end
  
  def self.mime_types(&block)
    if block_given?
      instance_eval &block
    else
      @mime_type_set ||= MimeTypeSet.new
    end
  end
  
  def self.mime_type(name, &block)
    mime_type = MimeType.new(name)
    mime_type.instance_eval &block
    mime_types << mime_type
  end
end
