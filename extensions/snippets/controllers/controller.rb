module Yodel
  class Controller
    def snippet(name)
      snippet = Snippet.first_for_site(site, {name: name})
      raise "Missing snippet: #{name}" if snippet.nil?
      snippet.content
    end
  end
end
