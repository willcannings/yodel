module Yodel
  class Page < Hierarchical
    can_be_root
    single_root
    searchable
    creatable
    default_child_type  self
    allowed_child_types self
    
    # core page attributes
    key :permalink, String, display: false, required: true, unique: true, index: true, searchable: false
    key :title, String, required: true
    key :content, HTML
    image :logo, thumb: '290x175'
    
    # behaviour tab
    key :show_in_menus, Boolean, tab: 'Behaviour'
    key :show_in_search, Boolean, tab: 'Behaviour'
    belongs_to :layout, class: Yodel::Layout, display: true, required: false, tab: 'Behaviour'
    
    # SEO tab
    key :description, Text, tab: 'SEO'
    key :keywords, Text, tab: 'SEO'
    key :custom_meta_tags, Text, tab: 'SEO', searchable: false
    
    def icon
      '/pages_static/images/page_icon.png'
    end
    
    def name
      title
    end
    
    before_validation_on_create :assign_permalink
    def assign_permalink
      self.permalink = self.title.parameterize('_')
    end
  end
end
