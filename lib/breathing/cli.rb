require 'thor'
require 'breathing'

module Breathing
  class Cli < Thor
    default_command :install

    desc 'install', 'Create table change_logs and create triggers'
    def install
      Breathing.install
    end

    desc 'uninstall', 'Drop table change_logs and drop triggers'
    def uninstall
      Breathing.uninstall
    end

    desc 'clear', 'Delete all records in change_logs table'
    def clear
      Breathing.clear
    end

    desc 'version', 'Show Version'
    def version
      say "Version: #{Breathing::VERSION}"
    end
  end
end
