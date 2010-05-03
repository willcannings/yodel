module Yodel
  class AdminDesignController < AdminListController
    handles  Yodel::Layout, Yodel::UploadFile, Yodel::EditableFile
    tab_name 'Design'
  end
end
