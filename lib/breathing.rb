require 'active_record'
require 'hairtrigger'
require 'breathing/installer'
require 'breathing/trigger'
require 'breathing/change_log'
require 'breathing/excel'
require 'breathing/terminal_table'

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

    def render_terminal_table(table_name:, id: 1)
      ActiveRecord::Base.establish_connection
      puts Breathing::TerminalTable.new(table_name).render(id: id)
    end

    def tail_f(table_name:, id: 1)
      ActiveRecord::Base.establish_connection
      table = Breathing::TerminalTable.new(table_name)

      loop do
        text = table.render(id: id)
        if text.present?
          puts text
          id = table.last_id + 1
        end
        sleep 5
      end
    end
  end
end
