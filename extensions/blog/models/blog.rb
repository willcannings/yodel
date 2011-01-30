module Yodel
  class Blog < Yodel::Page
    creatable
    allowed_child_types Yodel::Article
    belongs_to :article_layout, class: Yodel::Layout, display: true, required: true, tab: 'Behaviour'
    page_controller Yodel::BlogController
    
    def icon
      '/admin/images/blog_icon.png'
    end
    
    def blog
      self
    end

    def articles
      self.children
    end

    def tag_path(tag)
      "#{self.path}?tag=#{CGI::escape(tag || '')}"
    end
    
    def month_path(month, year)
      "#{self.path}?month=#{month}&year=#{year}"
    end

    def all_article_months
      counts = Hash.new(0)

      # generate a count of articles for each month
      children.each do |child|
        date = child.published.at_beginning_of_month
        counts[date] += 1
      end

      # collect the months into an array of counted values
      months = counts.each_pair.collect {|date, count| OpenStruct.new(date: date, count: count, path: self.month_path(date.month, date.year))}
      months.sort_by(&:date).reverse
    end

    def all_article_tags
      counts = Hash.new(0)

      # count the number of articles each tag appears in
      children.each do |child|
        child.tags.each do |tag|
          counts[tag] += 1
        end
      end

      # collect the tags into an array of counted values
      tags = counts.each_pair.collect {|tag, count| OpenStruct.new(tag: tag, count: count, path: self.tag_path(tag))}
      tags.sort_by(&:count).reverse
    end    
  end
end
