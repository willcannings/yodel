class CalendarMonths
  def initialize(events)
    @months = {}
    events.each {|event| add_event(event)}
  end
  
  def add_event(event)
    date = event.start_date.to_date.at_beginning_of_month
    if !@months.has_key?(date)
      @months[date] = CalendarMonth.new(date)
    end
    @months[date] << event
  end
  
  def months
    @months.values.sort_by(&:date).reverse
  end
end

class CalendarMonth
  attr_reader :date
  def initialize(date)
    @date = date
    @events = []
  end
  
  def <<(event)
    @events << event
  end
  
  def events
    @events.sort_by {|event| event.start_date}.reverse
  end
  
  def events_count
    @events.size
  end
end
