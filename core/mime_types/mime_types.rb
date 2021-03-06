Yodel.mime_types do
  mime_type :text do
    extensions 'txt'
    mime_types 'text/plain'
  end
  
  mime_type :html do
    extensions 'html', 'htm', 'shtml'
    mime_types 'text/html'
  end
  
  mime_type :css do
    extensions 'css'
    mime_types 'text/css'
  end
  
  mime_type :js do
    extensions 'js'
    mime_types 'text/javascript', 'application/javascript', 'application/x-javascript'
  end
  
  mime_type :json do
    extensions 'json'
    mime_types 'application/json'
    transformer do |data|
      data.to_json
    end
  end
  
  mime_type :atom do
    extensions 'atom'
    mime_types 'application/atom+xml'
    builder do
      Builder::XmlMarkup.new
    end
  end
  
  mime_type :xml do
    extensions 'xml'
    mime_types 'text/xml'
    builder do
      Builder::XmlMarkup.new
    end
  end
  
  mime_type :pdf do
    extensions 'pdf'
    mime_types 'application/pdf', 'application/x-pdf'
  end
  
  mime_type :png do
    extensions 'png'
    mime_types 'image/png'
  end
  
  mime_type :gif do
    extensions 'gif'
    mime_types 'image/gif'
  end
  
  mime_type :jpeg do
    extensions 'jpeg', 'jpg'
    mime_types 'image/jpeg'
  end
  
  mime_type :ics do
    extensions 'ics'
    mime_types 'text/calendar'
  end
  
  mime_type :csv do
    extensions 'csv'
    mime_types 'text/csv'
  end
end
