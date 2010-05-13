module Yodel
  class Blog < Yodel::Page
    creatable
    allowed_child_types Yodel::Article
    has_many :articles, class: Yodel::Article
    belongs_to :article_layout, class: Yodel::Layout, display: true, required: true, tab: 'Behaviour'
    
    def icon
      '/admin/images/blog_icon.png'
    end
    
    def articles
      @articles ||= children.sort_by{|article| article.published}.reverse
    end
    
    def blog
      self
    end

    def all_article_months
      counts = {}

      # generate a count of articles for each month
      children.each do |child|
        date = child.published.at_beginning_of_month
        if counts.key?(date)
          counts[date] += 1
        else
          counts[date] = 1
        end
      end

      # collect the months into an array of counted values
      months = counts.each_pair.collect {|date, count| OpenStruct.new(date: date, count: count)}
      months.sort_by(&:date).reverse
    end

    def all_article_tags
      counts = {}

      # count the number of articles each tag appears in
      children.each do |child|
        child.all_tags.each do |tag|
          if counts.key?(tag)
            counts[tag] += 1
          else
            counts[tag] = 1
          end
        end
      end

      # collect the tags into an array of counted values
      tags = counts.each_pair.collect {|tag, count| OpenStruct.new(tag: tag, count: count)}
      tags.sort_by(&:count).reverse
    end
  end
end
