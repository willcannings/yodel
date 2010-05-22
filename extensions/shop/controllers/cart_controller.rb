module Yodel
  class CartController < Controller
    route "/cart"
    route "/add_to_cart/(?<id>\\w+)", action: :add_to_cart
    route "/remove_from_cart/(?<id>\\w+)", action: :remove_from_cart
    
    def index
      @site = site
      @products = {}
      (session['cart'] || {}).each do |product_id, count|
        @products[Yodel::Product.first(id: product_id)] = count
      end
      @page = OpenStruct.new(title: 'Cart', path: '/cart', ancestors: [], root_record: Yodel::Page.all_for_site(site).first)
      html Yodel::Layout.first(name: 'Cart').render_with_controller(self)
    end
    
    def add_to_cart
      cart = session['cart'] || {}
      
      # looking up the product here means we don't allow adding random ID's to the cart list
      product = Yodel::Product.first(id: params['id'])
      if cart.has_key?(product.id)
        cart[product.id] += 1
      else
        cart[product.id] = 1
      end
      
      session['cart'] = cart
      response.redirect '/cart'
    end
    
    def remove_from_cart
      cart = session['cart'] || {}
      
      # looking up the product here means we don't allow adding random ID's to the cart list
      product = Yodel::Product.first(id: params['id'])
      if cart.has_key?(product.id)
        if cart[product.id] > 0
          cart[product.id] -= 1
        else
          cart.delete(product.id)
        end
      end
      
      session['cart'] = cart
      response.redirect '/cart'
    end
  end
end
