module Yodel
  class Event < Page
    allowed_child_types nil
    creatable
    page_controller Yodel::EventController
    
    key :byline, String
    key :start_date, Time, default: lambda { Time.now }
    key :end_date, Time, default: lambda { Time.now }
    key :location, String
    image :image, event: '382x253'
    
    def icon
      '/admin/images/event_icon.png'
    end
    
    def search_title
      'Event: ' + title
    end
    
    def root_calendar
      parent.parent
    end
    
    def layout
      parent.parent.event_layout
    end
    
    def export_to_calendar(calendar)
      calendar.event do |event|
        event.summary = self.title
        event.description = HTML.new(self.content).to_text
        event.location = self.location unless self.location.nil? || self.location.empty?
        event.categories = [self.parent.title]
        event.dtstart = self.start_date
        event.dtend = self.end_date
      end
    end    
  end
end
