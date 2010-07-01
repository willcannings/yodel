module Yodel
  class BlogController < PageController
    
    # FIXME: because we're using associations (children) to retrieve articles, I'm not
    # sure if we can use the mongo mapper Pagination module (didn't have time to check)
    # also need to extract ARTICLES_PER_PAGE
    ARTICLES_PER_PAGE = 5
    def show
      extra_options = {limit: ARTICLES_PER_PAGE}
      if params['page']
        extra_options[:skip] = params['page'].to_i * ARTICLES_PER_PAGE
      else
        extra_options[:skip] = 0
      end
      
      if params['tag']
        @articles = @page.children.all({tags: params['tag']}.merge(extra_options)).sort_by{|article| article.published}.reverse
        @total_articles = @page.children.count(tags: params['tag'])
      elsif params['month'] && params['year']
        year = params['year'].to_i
        month = [[params['month'].to_i, 1].max, 12].min # constrain the month between 1..12
        date_options = {:published.gte => Time.local(year, month, 1), :published.lte => Time.local(year, month + 1, 1)}
        @articles = @page.children.all(extra_options.merge(date_options)).sort_by{|article| article.published}.reverse
        @total_articles = @page.children.count(date_options)
      else
        @articles = @page.children.all(extra_options).sort_by{|article| article.published}.reverse
        @total_articles = @page.children.count
      end
      
      # render html as a normal page
      super
      
      # FIXME: work out why this is always being run even when the format isn't atom
      # potential atom feed for the blog
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
  end
end
