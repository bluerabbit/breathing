require 'active_record'
require 'breathing/installer'
require 'breathing/trigger'
require 'breathing/change_log'
require 'breathing/excel'

module Breathing
  VERSION = Gem.loaded_specs['breathing'].version.to_s

  class << self
    def install
      establish_connection
      Breathing::Installer.new.install
    end

    def uninstall
      establish_connection
      Breathing::Installer.new.uninstall
    end

    def clear
      establish_connection
      Breathing::ChangeLog.delete_all
    end

    def export
      establish_connection
      Breathing::Excel.new.create
    end

    def establish_connection
      ActiveRecord::Base.establish_connection(url: ENV['DATABASE_URL'])
    end
  end
end
