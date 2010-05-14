module Yodel
  class Video < Page
  end
  
  class VideoController < PageController
    def show
      @videos = @page.root_video_page.all_videos
      
      if @page.is_a?(Yodel::Video)
        @video = @page
      else
        @video = @videos.first
      end
      super
    end
  end
end
