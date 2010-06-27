module Yodel
  class EventController < PageController
    def show
      ics do
        RiCal.Calendar do |calendar|
          @page.export_to_calendar(calendar)
        end.to_s
      end      
      super
    end
  end
end
