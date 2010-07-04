module Yodel
  class VideoCategory < Page
    allowed_child_types Yodel::Video
    creatable
    page_controller Yodel::VideoController
    
    def icon
      '/admin/images/video_category_icon.png'
    end
    
    def root_video_page
      parent
    end
    
    def layout
      parent.category_layout
    end
  end
end
