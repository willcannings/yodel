class HTML < Text
  def search_terms_set
    # TODO: split out html tags, then do a normal word split
    []
  end
  
  def to_text
    Hpricot(self).search('text()').join(' ')
  end
end

class HTMLCode < Code
end
