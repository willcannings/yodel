module Yodel
  class Page < Hierarchical
    allowed_child_types self
    single_root
    searchable
    creatable
    
    # core page attributes
    key :permalink, String, display: false, required: true, index: true, searchable: false # unique: true not required because assign_permalink guarantees uniqueness
    key :title, String, required: true
    key :content, HTML
    
    # behaviour tab
    key :show_in_menus, Boolean, tab: 'Behaviour', default: true
    key :show_in_search, Boolean, tab: 'Behaviour', default: true
    belongs_to :page_layout, class: Yodel::Layout, display: true, required: false, tab: 'Behaviour'
    
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
    
    def show_in_search?
      show_in_search
    end
    
    def search_title
      title
    end
    
    # TODO: make sure this works?
    def paragraph(index, field=:content)
      text = self[field]
      paragraphs = Hpricot(text).search('/p')
      unless paragraphs.nil? || paragraphs[index].nil?
        paragraphs[index].inner_html
      else
        ''
      end
    end
    
    def paragraphs_from(index, field=:content)
      text = self[field]
      paragraphs = Hpricot(text).search('/p')
      unless paragraphs.nil? || paragraphs[index..-1].nil?
        paragraphs[index..-1].collect {|p| p.to_s}.join('')
      else
        ''
      end
    end
    
    # rendering pages requires knowing a page permalink and layout to be used
    before_validation_on_create :assign_permalink
    def assign_permalink
      base_permalink = self.title.parameterize('_')
      suffix = ''
      count  = 0
      
      # ensure other pages don't have the same path as this page
      page_siblings = self.siblings
      while !page_siblings.select {|page| page.permalink == base_permalink + suffix}.empty?
        count += 1
        suffix = "_#{count}"
      end
      
      self.permalink = base_permalink + suffix
    end
    
    def layout
      self.page_layout.nil? ? self.parent.layout : self.page_layout
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
      if controller
        @page_controller = controller
      else
        @page_controller
      end
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
