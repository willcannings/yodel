module Yodel
  class ShopCategory < Page
    allowed_child_types Yodel::Product
    creatable
    
    def icon
      '/admin/images/shop_category_icon.png'
    end
    
    def root_shop
      parent
    end
    
    def products
      children
    end
    
    def layout
      parent.category_layout
    end
  end
end
