# TODO: finish migrating from config to this class
module Yodel
  class YodelAdminEnvironment
    def initialize
      @tabs = []
    end
  end

  def self.admin
    @admin_environment ||= YodelAdminEnvironment.new
  end
end