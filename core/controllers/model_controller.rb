module Yodel
  class ModelController < Controller
    def self.route_prefix(prefix=nil)
      @route_prefix ||= prefix
    end
    
    def self.handles(model)
      @model = model
      @name = model.name.demodulize.singularize.underscore
      model.controller = self
      
      route "#{'/' + @route_prefix if @route_prefix}/#{@name.pluralize}", method: :get, action: :index
      route "#{'/' + @route_prefix if @route_prefix}/#{@name.pluralize}", method: :post, action: :create
      route "#{'/' + @route_prefix if @route_prefix}/#{@name}/(?<id>[0-9a-z]+)/destroy", method: :get, action: :destroy
      route "#{'/' + @route_prefix if @route_prefix}/#{@name}/(?<id>[0-9a-z]+)", method: :post, action: :update
      route "#{'/' + @route_prefix if @route_prefix}/#{@name}/(?<id>[0-9a-z]+)", method: :get, action: :show
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
      @records = self.class.model.all(site_id: site.id).collect(&:to_json_hash)
      json records: @records
    end
    
    def show
      @record = self.class.model.find(params['id'])
      status 404 if @record.nil?
      json record: @record.try(:to_json_hash), type: @record.class.name.demodulize.underscore
    end
    
    def destroy
      @record = self.class.model.find(params['id'])
      
      if @record.nil?
        status 404
        json success: false
      else
        @record.destroy
        json success: true
      end
    end
    
    def create
      @record = self.class.model.new
      @record.site = site
      update_record(@record)
    end
    
    def update
      @record = self.class.model.find(params['id'])
      update_record(@record)
    end
    
    private
      def update_record(record)
        values = params[self.class.name]
        
        # FIXME: this is some 3am coding.... this can surely be done a better way
        # handle associations specially
        self.class.model.associations.values.each do |association|
          # attachments are handled using mass assignment
          next if association.type == :one && association.klass.ancestors.include?(Yodel::Attachment)
          next unless association.query_options[:display] || association.name == :parent
          
          # FIXME: only handling belong_to associations for now
          if association.type == :belongs_to
            new_value = values[association.name.to_s]
            if new_value
              if new_value != ''
                record.send("#{association.name}=", Yodel::Record.find(new_value))
              else
                record.send("#{association.name}=", nil)
              end
            end
            
            values.delete(association.name.to_s)
          end
        end
        
        # handle booleans specially
        self.class.model.keys.values.each do |key|
          next unless key.type && key.type.ancestors.include?(Boolean)
          record.send("#{key.name}=", !values[key.name.to_s].nil?)
          values.delete(key.name.to_s)
        end
        
        # handle all other attributes using mass assignment
        if record.update_attributes(values)
          json record: record.to_json_hash
        else
          status 400
          json errors: record.errors.errors
        end
      end
  end
end
