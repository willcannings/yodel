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
    
    def root_shop
      parent.parent
    end
  end
end
