class BigDecimal
  def self.to_mongo(value)
    value.to_s
  end

  def self.from_mongo(value)
    BigDecimal.new(value.to_s || '')
  end
end

class Decimal < BigDecimal
end
