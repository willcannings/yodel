module Yodel
  class VideoPage < Page
    allowed_child_types Yodel::VideoCategory
    creatable
    page_controller Yodel::VideoController
    
    belongs_to :category_layout, class: Yodel::Layout, display: true, tab: 'Behaviour'
    belongs_to :video_layout, class: Yodel::Layout, display: true, tab: 'Behaviour'
    
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
