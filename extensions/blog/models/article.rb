module Yodel
  class Article < Yodel::Page
    allowed_child_types nil
    creatable
    
    belongs_to :author, class_name: 'Yodel::User', display: true
    key :published, Time, default: lambda { Time.now }, index: true
    key :tags, Tags, index: true
    image :image, article: '553x232'
    attachment :attachment

    def icon
      '/admin/images/article_icon.png'
    end
    
    def blog
      parent
    end
    
    def search_title
      'News: ' + title
    end
    
    def layout
      self.blog.article_layout
    end
  end
end
