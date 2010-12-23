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
    
    def tag_path(tag)
      "#{self.path}?tag=#{CGI::escape(tag)}"
    end
    
    def all_video_tags
      counts = Hash.new(0)

      # count the number of videos each tag appears in
      children.each do |category|
        category.children.each do |video|
          video.tags.each do |tag|
            counts[tag] += 1
          end
        end
      end

      # collect the tags into an array of counted values
      tags = counts.each_pair.collect {|tag, count| OpenStruct.new(tag: tag, count: count, path: self.tag_path(tag))}
      tags.sort_by(&:count).reverse
    end
  end
end
