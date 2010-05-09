module Yodel
  class EditableFileController < Controller
    route "/editable_file/(?<name>[0-9a-z]+)", action: :show
    
    def show
      name = params['name']
      name += params['format'] if params['format']
      file = Yodel::EditableFile.first_for_site(site, name: name)
      response.write file.content
      response['Content-Type'] = file.mime_type
    end
  end
end
