require 'breathing'
require 'terminal-table'

module Breathing
  class TerminalTable
    attr_reader :last_id

    def initialize(table_name)
      @last_id    = 1
      @table_name = table_name
    end

    def render(id: 1)
      rows = Breathing::ChangeLog.where(table_name: @table_name).where("id >= ? ", id).order(:id)

      return if rows.size.zero?

      @table = Terminal::Table.new(title:    rows.first.table_name,
                                   headings: rows.first.data_attributes.keys,
                                   rows:     rows.map { |row| row.data_attributes.values })

      @last_id = rows.last.id
      @table.to_s
    end

    def rows
      @table.rows
    end
  end
end
