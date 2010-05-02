# re-open the record class and add functionality

module Yodel
  class Record
    # class methods
    def self.tabs
      if !@tabs
        tabs = Set.new
        tabs << nil

        keys.each {|key| @tabs << key.options[:tab]}
        associations.each {|assoc| @tabs << assoc.query_options[:tab]}
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
      'default.png'
    end
  end
end
