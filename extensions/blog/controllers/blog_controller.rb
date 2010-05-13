module Yodel
  class BlogController < PageController
    def show
      super
      atom do |xml|
        xml.instruct!

        xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
          xml.title   @page.title
          xml.link    "rel" => "self", "href" => request.fullpath
          xml.link    "rel" => "alternate", "href" => @page.path
          xml.id      request.fullpath
          xml.updated @page.articles.first.published.strftime "%Y-%m-%dT%H:%M:%SZ" if @page.articles.any?
          xml.author  site.name

          @page.articles.each do |article|
            xml.entry do
              xml.title   article.title
              xml.link    "rel" => "alternate", "href" => article.path
              xml.id      article.path
              xml.updated article.published.strftime "%Y-%m-%dT%H:%M:%SZ"
              xml.author  { xml.name article.author.name } if !article.author.nil?
              xml.summary "Post summary"

              xml.content "type" => "html" do
                xml.text! article.content
              end
            end
          end  
        end
      end
    end
  end
end
