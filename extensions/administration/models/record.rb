module Yodel
  class Record
    def self.tabs
      unless @tabs
        tabs = Set.new
        tabs << nil # TODO: work out why this is necessary?

        keys.each {|key| @tabs << key.options[:tab]}
        associations.each {|assoc| @tabs << assoc.options[:tab]}
        @tabs = tabs.to_a
      end
      
      @tabs
    end
    
    def self.creatable?
      @creatable || false
    end
    
    def self.creatable
      @creatable = true
    end
    
    def icon
      '/admin/images/default_icon.png'
    end
  end
end
