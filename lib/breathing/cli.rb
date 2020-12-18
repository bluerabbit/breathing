# frozen_string_literal: true
require 'thor'
require 'breathing'

module Breathing
  class Cli < Thor
    default_command :export

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

    desc 'export', 'output xlsx'

    def export
      Breathing.export
    end

    desc 'out', 'output stdout'
    method_option :type, aliases: '-t', default: 'terminal_table', type: :string
    method_option :table, type: :string, required: true
    method_option :id, default: 1, type: :numeric
    def out
      if options[:table] == 'terminal_table'
        Breathing.render_terminal_table(table_name: options[:table], id: options[:id].to_i)
      else
        # TODO
        # Breathing.export(table_name: options[:table], id: options[:id].to_i)
      end
    end

    desc 'tail', 'tail terminal_table'
    method_option :table, type: :string, required: true
    method_option :id, default: 1, type: :numeric
    def tail
      Breathing.tail_f(table_name: options[:table], id: options[:id].to_i)
    end

    desc 'version', 'Show Version'

    def version
      say "Version: #{Breathing::VERSION}"
    end
  end
end
