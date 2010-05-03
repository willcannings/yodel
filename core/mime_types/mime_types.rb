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
end
