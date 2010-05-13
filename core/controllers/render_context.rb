module Yodel
  class RenderContext
    def initialize(controller, extra_context)
      controller.params.each_pair do |name, value|
        instance_variable_set variabalise_name(name), value
      end
    
      controller.instance_variables.each do |name|
        instance_variable_set name, controller.instance_variable_get(name)
      end
      
      extra_context.each do |key, value|
        instance_variable_set variabalise_name(key), value
      end
      
      @controller = controller
    end
  
    def method_missing(name, *args)
      name = name.to_s
    
      if !name.starts_with?('@')
        if @controller.respond_to?(name.to_sym)
          @controller.send(name.to_sym, *args)
        else
          super(name, args)
        end
      else
        if name.ends_with?('=')
          instance_variable_set name[0...-1], args.first
        elsif name.ends_with?('?')
          instance_variable_defined? name[0...-1]
        else
          instance_variable_defined?(name) ? instance_variable_get(name) : nil
        end
      end
    end
  
    def variabalise_name(name)
      '@' + name.to_s.gsub(' ', '').underscore
    end
  
    def set_value(name, value)
      instance_variable_set variabalise_name(name), value
    end
  
    def get_value(name)
      instance_variable_get variabalise_name(name)
    end
  end
end
