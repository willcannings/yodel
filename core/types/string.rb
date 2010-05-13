class String
  def search_terms_set
    self.gsub(/\W+/, ' ').split
  end
end
