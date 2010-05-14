module Yodel
  class ShopPage < Page
    allowed_child_types Yodel::ShopCategory
    creatable
    
    def icon
      '/admin/images/shop_page_icon.png'
    end
    
    def root_shop
      self
    end
    
    def products
      children.collect(&:children).flatten
    end
  end
end
