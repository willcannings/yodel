module Yodel
  class CalendarPage < Page
    allowed_child_types Yodel::Calendar
    creatable
    page_controller Yodel::CalendarController
    
    def icon
      '/admin/images/calendar_page_icon.png'
    end
    
    def root_calendar
      self
    end    
  end
end
