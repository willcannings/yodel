module Yodel
  class CalendarPage < Page
  end

  class CalendarController < PageController
    def show
      if @page.is_a?(Yodel::CalendarPage)
        @calendar = nil
        @events = []
        @page.children.each {|calendar| @events += calendar.children}
        @events = @events.sort_by {|event| event.start_date}
      else
        @calendar = @page
        @events = @calendar.children.sort_by {|event| event.start_date}
      end
      
      ics do
        RiCal.Calendar do |calendar|
          @events.each {|event| event.export_to_calendar(calendar)}
        end.to_s
      end
      
      @months = CalendarMonths.new(@events).months
      super
    end
  end
end
