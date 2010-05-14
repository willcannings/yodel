module Yodel
  class Event < Page
    allowed_child_types nil
    creatable
    
    key :byline, String
    key :start_date, Time, default: lambda { Time.now }
    key :end_date, Time, default: lambda { Time.now }
    image :image, event: '382x253'
    
    def icon
      '/admin/images/event_icon.png'
    end
    
    def search_title
      'Event: ' + title
    end
  end
end
