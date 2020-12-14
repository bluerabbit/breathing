require 'active_record'
require 'hairtrigger'
require 'breathing/installer'
require 'breathing/trigger'
require 'breathing/change_log'
require 'breathing/excel'

module Breathing
  VERSION = Gem.loaded_specs['breathing'].version.to_s

  class << self
    def install
      ActiveRecord::Base.establish_connection
      Breathing::Installer.new.install
    end

    def uninstall
      ActiveRecord::Base.establish_connection
      Breathing::Installer.new.uninstall
    end

    def clear
      ActiveRecord::Base.establish_connection
      Breathing::ChangeLog.delete_all
    end

    def export
      ActiveRecord::Base.establish_connection
      Breathing::Excel.new.create
    end
  end
end
