module Yodel
  class AdminDesignController < AdminListController
    handles  Yodel::UploadFile, Yodel::EditableFile
    tab_name 'Design'
  end
end
