module Yodel
  class Video < Page
    allowed_child_types nil
    creatable
    page_controller Yodel::VideoController
    
    key :published, Time, default: lambda { Time.now }
    key :youtube, String, required: true, searchable: false
    image :thumbnail, thumb: '202x131'
    
    def icon
      '/admin/images/video_icon.png'
    end
    
    def search_title
      'Video: ' + title
    end
    
    def root_video_page
      parent.parent
    end
    
    def layout
      parent.parent.video_layout
    end    
  end
end
