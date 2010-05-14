module Yodel
  class VideoPage < Page
    allowed_child_types Yodel::VideoCategory
    creatable
    page_controller Yodel::VideoController
    
    def icon
      '/admin/images/video_page_icon.png'
    end
    
    def root_video_page
      self
    end
    
    def all_videos
      self.children.collect(&:children).flatten
    end
  end
end
