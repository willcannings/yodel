# because of the circular reference between sites and records, we can't
# define the models in separate classes

module Yodel
  class Record
    include ::MongoMapper::Document
    extend Yodel::Searchable
    set_collection_name 'record'
    
    def self.self_and_descendants
      [self] + self.descendants
    end
    
    def self.self_and_all_descendants
      types = Set[self]
      self.descendants.each do |child|
        types << child
        types.merge child.descendants
      end
      types.to_a
    end
    
    # sharding can be performed on site_id's
    belongs_to :site, class_name: 'Yodel::Site'
    ensure_index 'site_id'
    
    def self.all_for_site(site, conditions={})
      records = self.all({site_id: site.id}.merge(conditions)) + self.descendants.collect {|child| child.all_for_site(site, conditions)}.flatten
      if sort_by
        records.sort_by {|record| record.send(sort_by)}
      else
        records
      end
    end
    
    def self.sort_by(sym=nil)
      @sort_by ||= sym
    end
    
    def self.first_for_site(site, conditions={})
      record = self.first({site_id: site.id}.merge(conditions))
      children = self.descendants
      
      while !record && !children.empty?
        child = children.shift
        record = child.first({site_id: site.id}.merge(conditions))
      end
      
      record
    end
    
    
    # when records are referred to via an association,
    # they need to be able to respond with a human
    # readable name. this method should be overriden.
    def name
      self._id.to_s
    end
    
    # FIXME: this needs to be extracted out to the different key types?
    def self.cleanse_hash(hash)
      # for readability rename '_id' to 'id',
      # and '_type' to 'type'
      if hash.has_key?('_id')
        id = hash.delete('_id')
        hash['id'] = id.to_s
      end
      if hash.has_key?('_type')
        type = hash.delete('_type')
        hash['type'] = type
      end
      
      # we don't need to store which site the record belongs to
      hash.delete('site_id')
      
      # or the search keywords that are generated
      hash.delete('yodel_search_keywords') if hash.has_key?('yodel_search_keywords')
      
      # attributes starting with an underscore are private
      hash.delete_if {|key, value| key.start_with? '_'}
      
      # change all references (values of type ObjectID)
      # to a string of the object ID, cleanse embedded
      # documents, remove "_id" from all keys, and change
      # date and time values in to a format suitable for
      # clients to read appropriately
      hash.keys.each do |key|
        value = hash[key]
        hash[key] = value.to_s if value.is_a?(BSON::ObjectId)
        hash[key] = cleanse_hash(value) if value.is_a?(Hash)
        hash[key] = value.force_encoding("UTF-8") if value.is_a?(String)
        
        if self.keys[key].try(:type) && self.keys[key].type.ancestors.include?(Tags)
          hash[key] = Tags.new(value).to_s
          next
        end
        
        if key.end_with?('_id')
          hash.delete(key)
          value_key = key.gsub('_id', '')
          hash[value_key] = value unless hash.has_key?(value_key)
          next
        end
        
        # hack to get around mongo mapper mapping all dates to time objects...
        if value.is_a?(Time) || value.is_a?(Date)
          if self.keys.has_key?(key) && !self.keys[key].type.nil?
            type = self.keys[key].type
          else
            type = value.class
          end
        
          if type.ancestors.include?(Date)
            hash[key] = value.strftime("%d %b %Y")
          elsif type.ancestors.include?(Time)
            # FIXME: this is just horrible.... only done to make the admin interface easy
            hash.delete(key)
            hash[key + '_date'] = value.strftime("%d %b %Y")
            hash[key + '_hour'] = value.hour
            hash[key + '_min']  = value.min
          end
          next
        end
        
        # has_many associations stored in an array need
        # to have ObjectID's converted to strings
        if value.is_a?(Array)
          hash[key] = value.collect do |val|
            val.is_a?(BSON::ObjectId) ? val.to_s : val
          end
        end
      end
      
      hash
    end
    
    def to_json_hash
      self.class.cleanse_hash(attributes)
    end
    
    def self.default_values
      {}.tap do |values|
        keys.each_value do |key|
          next unless !key.default_value.nil?
          values[key.name] =
            if key.default_value.respond_to?(:call)
              key.default_value.call
            else
              key.default_value
            end
        end
      end
    end
    
    def self.default_values_to_json_hash
      cleanse_hash(default_values)
    end
    
    # attachment helpers
    def self.attachment(name)
      class_eval "has_one :#{name}, class: Yodel::Attachment, dependent: :destroy, display: true"
      define_attachment_setter(name)
    end
    
    def self.unique_attachment(name)
      class_eval "has_one :#{name}, class: Yodel::UniqueAttachment, dependent: :destroy, display: true"
      define_attachment_setter(name)
    end
    
    def self.image(name, sizes={})
      class_eval "has_one :#{name}, class: Yodel::ImageAttachment, dependent: :destroy, display: true, sizes: #{{admin_thumb:"100x100"}.merge(sizes).inspect}"
      define_attachment_setter(name)
    end
    
    
    # record classes can have an associated controller
    # TODO: records should be able to have multiple controller types, e.g controller admin: bla, page: other
    def self.controller=(controller)
      @controller = controller
    end
    
    def controller
      self.class.controller
    end
    
    def self.controller(controller=nil)
      @controller ||= controller
    end
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@controller', @controller)
      child.instance_variable_set('@sort_by', @sort_by)
    end
    
    private
      def self.define_attachment_setter(name)
        class_eval "
          def #{name}=(file)
            return if file.nil?
            build_#{name} if #{name}.nil?
            if file[:tempfile]
              #{name}.build if #{name}.nil?
              #{name}.attachment_name = '#{name}'
              #{name}.set_file(file)
            else
              #{name}.replace(file)
            end
          end
        "
      end
  end  
end
