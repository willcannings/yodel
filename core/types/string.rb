class String
  def search_terms_set
    self.gsub(/\W+/, ' ').split.sort.uniq
  end
end
