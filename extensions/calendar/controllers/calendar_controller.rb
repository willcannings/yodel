module Yodel
  class CalendarPage < Page
  end

  class CalendarController < PageController
    def show
      get_events
      
      ics do
        RiCal.Calendar do |calendar|
          @events.each {|event| event.export_to_calendar(calendar)}
        end.to_s
      end
      
      @months = CalendarMonths.new(@events).months
      super
    end
    
    def get_events
      if @page.is_a?(Yodel::CalendarPage)
        @events = []
        @page.children.each {|calendar| @events += calendar.children}
        @events = @events.sort_by(&:start_date)
      else
        @calendar = @page
        @events = @calendar.children.all(options).sort_by(&:start_date)
      end
    end
  end
end
