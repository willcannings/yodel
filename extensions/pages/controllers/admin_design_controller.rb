module Yodel
  class AdminDesignController < AdminListController
    handles  :layouts, :upload_files, :editable_files
    tab_name 'Design'
  end
end
