module Yodel
  class BlogController < PageController
    def show
      if params['tag']
        @articles = @page.children.all(tags: params['tag']).sort_by{|article| article.published}.reverse

      elsif params['month'] && params['year']
        # FIXME: optimise for an actual date search (does Mongo even support this!?)
        @articles = @page.children.all.sort_by{|article| article.published}.reverse
        month = params['month'].to_i
        year = params['year'].to_i
        @articles.reject! do |article|
          article.published.month != month || article.published.year != year
        end
      else
        @articles = @page.children.all.sort_by{|article| article.published}.reverse
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
