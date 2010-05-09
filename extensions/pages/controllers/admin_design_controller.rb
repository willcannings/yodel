module Yodel
  class AdminDesignController < AdminListController
    handles  Yodel::UploadFile, Yodel::CSSFile, Yodel::JavascriptFile
    tab_name 'Design'
  end
end
