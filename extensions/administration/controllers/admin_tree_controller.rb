module Yodel
  class AdminTreeController < AdminController
    # hierarchical models are handled differently; it's assumed only
    # hierarchical types will be used with this controller, and won't
    # be used in the list controller
    def self.controller_models
      models = Set.new
      @handles.each do |model|
        models << model
        model.allowed_child_types.each {|child| models << child}
      end
      models.to_a.select {|model| model.creatable?}
    end
    
    def controller_models
      self.class.controller_models
    end
  end
end