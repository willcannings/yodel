module Yodel
  class Page < Hierarchical
    allowed_child_types self
    single_root
    searchable
    creatable
    
    # core page attributes
    key :permalink, String, display: false, required: true, unique: true, index: true, searchable: false
    key :title, String, required: true
    key :content, HTML
    
    # behaviour tab
    key :show_in_menus, Boolean, tab: 'Behaviour', default: true
    key :show_in_search, Boolean, tab: 'Behaviour', default: true
    belongs_to :layout, class: Yodel::Layout, display: true, required: false, tab: 'Behaviour'
    
    # SEO tab
    key :description, Text, tab: 'SEO'
    key :keywords, Text, tab: 'SEO'
    key :custom_meta_tags, Text, tab: 'SEO', searchable: false
    
    
    # admin interface
    def icon
      '/admin/images/page_icon.png'
    end
    
    def name
      title
    end
    
    
    # rendering pages requires knowing a page permalink and layout to be used
    before_validation_on_create :assign_permalink
    def assign_permalink
      self.permalink = self.title.parameterize('_')
    end
    
    def find_layout
      self.layout.nil? ? self.parent.find_layout : self.layout
    end
    
    def child_page_with_permalink(permalink)
      self.children.all.each {|child| return child if child.permalink == permalink}
      nil
    end
    
    def path
      # the first ancestor is the root page (we ignore its permalink since it is accessed by '/')
      '/' + ancestors.reverse[1..-1].collect(&:permalink).join('/')
    end
    
    # page controller
    def self.page_controller(controller=nil)
      @page_controller ||= controller
    end
    
    def page_controller
      self.class.page_controller
    end
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@page_controller', @page_controller)
    end
    
    page_controller Yodel::PageController
  end
end
