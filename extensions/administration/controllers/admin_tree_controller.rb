module Yodel
  class AdminTreeController < AdminController
    def index
      if session['selected']
        @selected_record = Yodel::Record.find(session['selected'])
        session.delete('selected')
      end
      
      @roots = root_type.roots_for_site(site)
      @content = render_file(File.join(File.dirname(__FILE__), '..', 'views', 'tree.html.erb'))
      super
    end
    
    def self.root_type
      @root_type ||= controller_models.first
    end
    
    def root_type
      self.class.root_type
    end
    
    def self.controller_models
      raise "Admin Tree Controller can only handle a single record type" if @handles.size > 1
      raise "This Admin Tree Controller (#{self.name}) doesn't have a 'handles' clause. You must specify a record type for this controller to handle" if @handles.nil? || @handles.empty?
      
      if !@controller_models
        models = Set.new
        models << @handles.first
        @handles.first.allowed_child_types.each do |model|
          models << model
        end
        @controller_models = models.to_a.select {|model| model.creatable?}
      end
      @controller_models
    end
    
    def controller_models
      self.class.controller_models
    end
    
    def self.first_creatable_root_type
      if !@first_creatable_root_type
        root_type.self_and_descendents.each do |type|
          if type.creatable?
            @first_creatable_root_type = type
            break
          end
        end
      end
      @first_creatable_root_type
    end
    
    def first_creatable_root_type
      self.class.first_creatable_root_type
    end
  end
end
