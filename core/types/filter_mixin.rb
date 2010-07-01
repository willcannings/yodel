module FilterMixin
  def self.included(mod)
    mod.class_eval do
      def self.to_mongo(value)
        Hpricot(value.to_s).search('text()').collect(&:to_s).collect(&:strip).join(' ').strip
      end

      def self.from_mongo(value)
        value.to_s
      end
    end
  end
end
