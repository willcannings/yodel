class Tags < Array
  def search_terms_set
    self
  end
  
  def self.from_string(tags)
    Tags.new(tags.split(',').map(&:strip).reject(&:blank?).uniq)
  end
  
  def to_s
    self.join(', ')
  end
  
  def self.to_mongo(value)
    value
  end

  def self.from_mongo(value)
    if value.is_a?(String)
      Tags.from_string(value)
    elsif value.nil?
      Tags.new
    else
      Tags.new(value)
    end
  end
end
