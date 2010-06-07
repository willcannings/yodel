module Yodel
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
    
    def directory_path
      @directory_path ||= Yodel.config.public_directory.join(self.identifier)
    end
  end
end
