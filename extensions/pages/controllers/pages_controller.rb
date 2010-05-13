module Yodel
  class PagesController < Controller
    route '/', last: true, action: :show
    
    def show
      page = Yodel::Page.roots_for_site(site).first
      params['glob'].scan(/[^\/]+/) do |component|
        page = page.child_page_with_permalink(component)
        status(404) and return if page.nil?
      end
      
      controller = page.page_controller.new(@request, @response, @site)
      controller.instance_variable_set('@page', page)
      controller.handle_request_with_action(:show)
    end
  end
end
