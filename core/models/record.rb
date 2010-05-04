# because of the circular reference between sites and records, we can't
# define the models in separate classes

module Yodel
  class Record
    include ::MongoMapper::Document
    extend Yodel::Searchable
    set_collection_name 'record'
    
    # sharding can be performed on site_id's
    belongs_to :site, class_name: 'Yodel::Site'
    ensure_index 'site_id'
    
    # when records are referred to via an association,
    # they need to be able to respond with a human
    # readable name. this method should be overriden.
    def name
      self._id.to_s
    end
    
    def to_json_hash
      attrs = self.attributes
      attrs.delete('_id')
      attrs['id'] = self.id.to_s
      attrs
    end
    
    # attachment helpers
    def self.attachment(name)
      class_eval "has_one :#{name}, class: Yodel::Attachment, dependent: :destroy, display: true"
      define_attachment_setter(name)
    end
    
    def self.image(name, sizes={})
      class_eval "has_one :#{name}, class: Yodel::ImageAttachment, dependent: :destroy, display: true, sizes: #{sizes.inspect}"
      define_attachment_setter(name)
    end
    
    # record classes can have an associated controller
    def self.controller=(controller)
      @controller = controller
    end
    
    def self.controller
      @controller
    end
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@controller', @controller)
    end
    
    private
      def self.define_attachment_setter(name)
        class_eval "
          def #{name}=(file)
            #{name}.build(attachment_name: '#{name}') if #{name}.nil?
            #{name}.set_file(file)
          end
        "
      end
  end  
end