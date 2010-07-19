module Yodel
  class Controller
    def snippet(name)
      Snippet.first_for_site(site, {name: name}).content
    end
  end
end
