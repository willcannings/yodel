module Yodel
  class CalendarPage < Page
    allowed_child_types Yodel::Calendar
    creatable
    page_controller Yodel::CalendarController
    
    belongs_to :calendar_layout, class: Yodel::Layout, display: true, tab: 'Behaviour'
    belongs_to :event_layout, class: Yodel::Layout, display: true, tab: 'Behaviour'
    
    def icon
      '/admin/images/calendar_page_icon.png'
    end
    
    def root_calendar
      self
    end    
  end
end
