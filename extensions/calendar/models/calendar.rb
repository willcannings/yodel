module Yodel
  class Calendar < Page
    allowed_child_types Yodel::Event
    creatable
    page_controller Yodel::CalendarController
    
    def icon
      '/admin/images/calendar_icon.png'
    end
    
    def root_calendar
      parent
    end
  end
end
