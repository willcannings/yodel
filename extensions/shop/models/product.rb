module Yodel
  class Product < Page
    allowed_child_types nil
    creatable
    
    image :image, product: '439x268', thumb: '217x132'
    key :price, Decimal
    
    def icon
      '/admin/images/product_icon.png'
    end
    
    def search_title
      'Product: ' + title
    end
    
    def name
      "#{self.title} ($#{"%.2f" % self.price})"
    end
    
    def root_shop
      parent.parent
    end
    
    def layout
      parent.parent.product_layout
    end
  end
end
