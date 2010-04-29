# because of the circular reference between sites and records, we can't
# define the models in separate classes

module Yodel
  class Record
    include ::MongoMapper::Document
    extend Yodel::Searchable
    set_collection_name 'record'
    
    # sharding can be performed on site_id's
    belongs_to :site
    ensure_index 'site_id'
    
    # attachment helpers
    def self.attachment(name)
      class_eval "
        has_one #{name.to_sym}, class: Yodel::Attachment, dependent: :destroy, display: true
        def #{name.to_s}=(value)
        end
      "
    end
    
    def self.image(name, dimensions)
      class_eval "
        has_one #{name.to_sym}, class: Yodel::ImageAttachment, dependent: :destroy, display: true, dimensions: '#{dimensions}'
        def #{name.to_s}=(value)
        end
      "
    end
  end
  
  class Site
    include ::MongoMapper::Document
    set_collection_name 'site'
    has_many :records, class: Yodel::Record, dependent: :destroy
    
    key :name, String, required: true
    key :identifier, String, required: true
    key :domains, Array, required: true, default: [], index: true
    
    def self.find_by_domain(domain)
      Site.first domains: domain
    end
    
    def self.find_by_identifier(identifier)
      Site.first identifier: identifier
    end
  end
end
