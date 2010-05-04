module Yodel
  class Page < Hierarchical
    can_be_root
    single_root
    searchable
    creatable
    
    # core page attributes
    key :permalink, String, display: false, required: true, unique: true, index: true, searchable: false
    key :title, String, required: true
    key :content, HTML
    
    # behaviour tab
    key :show_in_menus, Boolean, tab: 'Behaviour'
    key :show_in_search, Boolean, tab: 'Behaviour'
    belongs_to :layout, class: Yodel::Layout, display: true, required: false, tab: 'Behaviour'
    
    # SEO tab
    key :description, Text, tab: 'SEO'
    key :keywords, Text, tab: 'SEO'
    key :custom_meta_tags, Text, tab: 'SEO', searchable: false    
  end
end
