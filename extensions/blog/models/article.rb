module Yodel
  class Article < Yodel::Page
    allowed_child_types nil
    creatable
    
    belongs_to :author, class_name: 'Yodel::User', display: true
    key :published, Time, default: lambda { Time.now }
    key :tags, String
    image :image, article: '553x232'
    attachment :attachment

    def icon
      '/admin/images/article_icon.png'
    end
    
    def blog
      parent
    end
    
    def find_layout
      self.blog.article_layout
    end
    
    def all_tags
      (self.tags || '').split(',').collect {|tag| tag.strip}.uniq
    end

    def has_tag(tag)
      all_tags.include?(tag)
    end

    def paragraph(index)
      paragraphs = Hpricot(content).search('/p')
      paragraph = paragraphs[index].inner_html
    end

    def paragraphs_from(index)
      paragraphs = Hpricot(content).search('/p')
      paragraphs[index..-1].collect {|p| p.to_s}.join('')
    end
  end
end
