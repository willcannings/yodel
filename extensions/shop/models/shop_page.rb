module Yodel
  class ShopPage < Page
    allowed_child_types Yodel::ShopCategory
    creatable
    
    belongs_to :category_layout, class: Yodel::Layout, display: true, tab: 'Behaviour'
    belongs_to :product_layout, class: Yodel::Layout, display: true, tab: 'Behaviour'
    
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
