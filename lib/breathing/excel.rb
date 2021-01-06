require 'rubyXL'
require 'rubyXL/convenience_methods'
require 'breathing'

module Breathing
  class Excel
    def initialize
      @workbook = RubyXL::Workbook.new
    end

    def create(id: 1, file_name: 'breathing.xlsx')
      sheet       = @workbook[0]
      table_names = Breathing::ChangeLog.where('id >= ?', id).group(:table_name).pluck(:table_name)
      table_names.sort.each do |table_name|
        if sheet.sheet_name == 'Sheet1'
          sheet.sheet_name = table_name
        else
          sheet = @workbook.add_worksheet(table_name)
        end

        rows = Breathing::ChangeLog.where(table_name: table_name).where('id >= ?', id).order(:id).to_a

        next if rows.size.zero?

        add_header_row(sheet, rows.first)
        add_body_rows(sheet, rows)
        add_style(sheet)
      end

      if table_names.size.positive?
        add_change_logs_sheet(id)
        @workbook.worksheets.rotate!(-1)
      end
      @workbook.write(file_name)
    end

    private

    def add_header_row(sheet, row)
      header_color = 'ddedf3' # blue
      foreign_keys = ActiveRecord::Base.connection.foreign_keys(sheet.sheet_name)
      row.data_attributes.keys.each.with_index do |header_column, column_index|
        cell = sheet.add_cell(0, column_index, header_column)
        cell.change_fill(header_color)
        if column_index == 0
          add_hyperlink(sheet: sheet, cell: cell, to_sheet: 'change_logs', to_cell: 'A1')
        end

        if key = foreign_keys.detect { |k| k.options[:column] == header_column }
          add_hyperlink(sheet: sheet, cell: cell, to_sheet: key.to_table, to_cell: 'A1')
        end
      end
    end

    def add_body_rows(sheet, rows)
      rows.each.with_index(1) do |row, row_number|
        row.data_attributes.each.with_index do |(column_name, value), column_index|
          cell = sheet.add_cell(row_number, column_index, value)
          if row.action == 'UPDATE' && column_name != 'updated_at' && row.changed_attribute_columns.include?(column_name)
            cell.change_fill('ffff00') # color: yellow
          elsif row.action == 'DELETE'
            cell.change_fill('d9d9d9') # color: grey
          end
        end
      end
    end

    def add_style(sheet)
      sheet.sheet_data.rows.each.with_index do |row, row_index|
        row.cells.each.with_index do |cell, column_index|
          %i[top bottom left right].each do |direction|
            cell.change_border(direction, 'thin')
          end
          cell.change_border(:bottom, 'double') if row_index.zero?

          cell_width = cell.value.to_s.size + 2
          sheet.change_column_width(column_index, cell_width) if cell_width > sheet.get_column_width(column_index)
        end
      end

      sheet.change_row_horizontal_alignment(0, 'center')
    end

    def add_change_logs_sheet(id)
      sheet = @workbook.add_worksheet(Breathing::ChangeLog.table_name)

      change_logs = Breathing::ChangeLog.where('id >= ?', id).order(:id)
      change_logs.first.attributes_for_excel.keys.each.with_index do |header_column, column_index|
        cell = sheet.add_cell(0, column_index, header_column)
        cell.change_fill('ddedf3') # blue
      end

      change_logs.each.with_index(1) do |change_log, row_number|
        change_log.attributes_for_excel.each.with_index do |(column_name, value), column_index|
          cell = sheet.add_cell(row_number, column_index, value)

          if column_name == 'table_name'
            add_hyperlink(sheet: sheet, cell: cell, to_sheet: value, to_cell: 'A1')
          end
        end
      end

      add_style(sheet)
    end

    def add_hyperlink(sheet:, cell:, to_sheet:, to_cell:)
      sheet.hyperlinks ||= RubyXL::Hyperlinks.new
      sheet.hyperlinks << RubyXL::Hyperlink.new(ref: RubyXL::Reference.ind2ref(cell.row, cell.column), location: "#{to_sheet}!#{to_cell}")
      cell.change_font_underline(true)
      cell.change_font_color('1F1FFF') # blue
    end
  end
end
