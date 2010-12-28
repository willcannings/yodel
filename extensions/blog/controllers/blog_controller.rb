module Yodel
  class BlogController < PageController
    
    # FIXME: because we're using associations (children) to retrieve articles, I'm not
    # sure if we can use the mongo mapper Pagination module (didn't have time to check)
    # also need to extract ARTICLES_PER_PAGE
    ARTICLES_PER_PAGE = 5
    def show
      extra_options = {limit: ARTICLES_PER_PAGE, order: 'published desc'}
      @page_number = params['page'].to_i
      extra_options[:skip] = @page_number * ARTICLES_PER_PAGE      
      
      if params['tag']
        @tag = params['tag']
        @articles = @page.children.all({tags: @tag}.merge(extra_options))
        @total_articles = @page.children.count(tags: @tag)
        @page_params = "tag=#{params['tag']}&"
        
      elsif params['month'] && params['year']
        @month = [[params['month'].to_i, 1].max, 12].min # constrain the month between 1..12
        @year  = params['year'].to_i
        date_options = {:published.gte => Time.local(@year, @month, 1), :published.lte => Time.local(@year, @month + 1, 1)}
        @articles = @page.children.all(extra_options.merge(date_options))
        @total_articles = @page.children.count(date_options)
        @page_params = "year=#{params['year']}&month=#{params['month']}&"
        
      else
        @articles = @page.children.all(extra_options)
        @total_articles = @page.children.count
        @page_params = ''
      end
      
      # helper variables
      @number_of_pages = (@total_articles.to_f / ARTICLES_PER_PAGE).ceil
      
      # render html as a normal page
      super
      
      atom do |xml|
        xml.instruct!

        xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
          xml.title   @page.title
          xml.link    "rel" => "self", "href" => request.url
          xml.link    "rel" => "alternate", "href" => URI.escape(request.scheme_and_host + @page.path)
          xml.id      request.url
          xml.updated @page.articles.first.published.strftime "%Y-%m-%dT%H:%M:%SZ" if @page.articles.any?
          xml.summary @page.description
          xml.author do
            xml.name site.name
          end

          @page.articles.each do |article|
            xml.entry do
              xml.title   article.title
              xml.link    "rel" => "alternate", "href" => article.path
              xml.id      URI.escape(request.scheme_and_host + article.path)
              xml.updated article.published.strftime "%Y-%m-%dT%H:%M:%SZ"
              xml.author  { xml.name article.author.name } if !article.author.nil?
              xml.summary HTML.new(article.content).to_text

              xml.content "type" => "html" do
                xml.text! article.content
              end
              
              unless article.attachment.nil?
                xml.link "rel" => "enclosure", "type" => article.attachment.mime_type, "href" => URI.escape(request.scheme_and_host + article.attachment.url.to_s), "length" => article.attachment.length
              end
            end
          end
        end
      end
    end
    
    def first_page?
      @page_number == 0
    end
    
    def last_page?
      @page_number == @number_of_pages - 1
    end
  end
end
