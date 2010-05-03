module Yodel
  class ModelController < Controller
    def self.route_prefix(prefix=nil)
      @route_prefix ||= prefix
    end
    
    def self.handles(model)
      @model = model
      @name = model.name.split('::')[-1].to_s.singularize.underscore
      model.controller self
      
      route "#{'/' + @route_prefix if @route_prefix}/#{@name.pluralize}", method: :get, action: :index
      route "#{'/' + @route_prefix if @route_prefix}/#{@name.pluralize}", method: :post, action: :create
      route "#{'/' + @route_prefix if @route_prefix}/#{@name}/(?<id>\d+)/destroy", method: :get, action: :destroy
      route "#{'/' + @route_prefix if @route_prefix}/#{@name}/(?<id>\d+)", method: :post, action: :update
      route "#{'/' + @route_prefix if @route_prefix}/#{@name}/(?<id>\d+)", method: :get, action: :show
    end
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@route_prefix', @route_prefix)
      child.instance_variable_set('@model', @model)
      child.instance_variable_set('@name', @name)
    end
    
    def self.model
      @model
    end
    
    def self.name
      @name
    end
    
    def index
      records = self.class.model.all(site_id: site.id).collect(&:to_json_hash)
      json records: records
    end
    
    def show
      record = self.class.model.find(params['id'])
      status 404 if record.nil?
      json record: record.try(:to_json_hash)
    end
    
    def destroy
      record = self.class.model.find(params['id'])
      
      if record.nil?
        status 404 if record.nil?
      else
        record.destroy
        json success: true
      end
    end
    
    def create
      record = self.class.model.new
      record.site = site
      update_record(record)
    end
    
    def update
      record = self.class.model.find(params['id'])
      update_record(record)
    end
    
    private
      def update_record(record)
        if record.update_attributes(params[self.class.name])
          json record: record.to_json_hash
        else
          status 400
          json errors: record.errors.errors
        end
      end
  end
end
