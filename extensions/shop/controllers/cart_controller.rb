module Yodel
  class CartController < Controller
    route "/cart"
    route "/add_to_cart/(?<id>\\w+)", action: :add_to_cart
    route "/remove_from_cart/(?<id>\\w+)", action: :remove_from_cart
    route "/checkout", action: :checkout
    route "/finish", action: :finish
    
    # TODO: products hash as before filter
    def index
      build_products_hash
      @page = OpenStruct.new(title: 'Cart', path: '/cart', ancestors: [], root_record: Yodel::Page.all_for_site(site).first)
      @just_added = Yodel::Record.first(id: session.delete('just_added'))
      html Yodel::Layout.first(name: 'Cart').render_with_controller(self)
    end
    
    def checkout
      build_products_hash
      @page = OpenStruct.new(title: 'Checkout', path: '/checkout', ancestors: [], root_record: Yodel::Page.all_for_site(site).first)
      html Yodel::Layout.first(name: 'Checkout').render_with_controller(self)
    end
    
    def finish
      session['cart'] = {}
      @page = OpenStruct.new(title: 'Finished', path: '/finish', ancestors: [], root_record: Yodel::Page.all_for_site(site).first)
      html Yodel::Layout.first(name: 'Finish').render_with_controller(self)
    end
    
    def add_to_cart
      cart = session['cart'] || {}
      
      # looking up the product here means we don't allow adding random ID's to the cart list
      product = Yodel::Record.first(id: params['id'])
      if cart.has_key?(product.id)
        cart[product.id] += 1
      else
        cart[product.id] = 1
      end
      
      session['just_added'] = product._id.to_s
      session['cart'] = cart
      response.redirect '/cart'
    end
    
    def remove_from_cart
      cart = session['cart'] || {}
      
      # looking up the product here means we don't allow adding random ID's to the cart list
      product = Yodel::Record.first(id: params['id'])
      if cart.has_key?(product.id)
        if cart[product.id] > 1
          cart[product.id] -= 1
        else
          cart.delete(product.id)
        end
      end
      
      session['cart'] = cart
      response.redirect '/cart'
    end
    
    
    private
      def build_products_hash
        @products = {}
        (session['cart'] || {}).each do |product_id, count|
          @products[Yodel::Record.first(id: product_id)] = count
        end
      end
  end
end
