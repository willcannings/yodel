module Yodel
  class Page < Hierarchical
    searchable
    creatable
    
    # core page attributes
    key :permalink, String, display: false, required: true, unique: true, index: true, searchable: false
    key :title, String, required: true
    key :content, String, display_as: :html
    
    # behaviour tab
    key :show_in_menus, Boolean, tab: 'Behaviour'
    key :show_in_search, Boolean, tab: 'Behaviour'
    belongs_to :layout, class: Yodel::Layout, display: true, required: false, tab: 'Behaviour'
    
    # SEO tab
    key :description, String, display_as: :text, tab: 'SEO'
    key :keywords, String, display_as: :text, tab: 'SEO'
    key :custom_meta_tags, String, display_as: :text, tab: 'SEO', searchable: false
  end
end
