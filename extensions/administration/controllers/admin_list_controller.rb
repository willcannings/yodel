module Yodel
  class AdminListController < AdminController
    def index
      if session['selected']
        @selected_record = Yodel::Record.find(session['selected'])
        session.delete('selected')
      end
      
      @content = render_file(File.join(File.dirname(__FILE__), '..', 'views', 'list.html.erb'))
      super
    end
    
    def self.controller_models
      return [] if @handles.nil?
      if !@controller_models
        models = Set.new
        @handles.each do |model|
          models << model
          model.descendants.each {|child| models << child}
        end
        @controller_models = models.to_a.select {|model| model.creatable?}
      end
      @controller_models
    end
    
    def controller_models
      self.class.controller_models
    end
  end
end
