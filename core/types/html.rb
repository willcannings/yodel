class HTML < Text
  def search_terms_set
    # TODO: split out html tags, then do a normal word split
    []
  end
end

class HTMLCode < Code
end
