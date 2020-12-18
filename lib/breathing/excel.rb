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
      table_names.each do |table_name|
        if sheet.sheet_name == 'Sheet1'
          sheet.sheet_name = table_name
        else
          sheet = @workbook.add_worksheet(table_name)
        end

        rows          = Breathing::ChangeLog.where(table_name: table_name).where('id >= ?', id).order(:id)
        column_widths = []

        if first_row = rows.first
          add_header_row(sheet, first_row, column_widths)
        end
        add_body_rows(sheet, rows, column_widths)

        column_widths.each.with_index(0) do |size, i|
          sheet.change_column_width(i, size + 2)
        end
        add_style(sheet)
      end

      @workbook.write(file_name)
    end

    private

    def add_header_row(sheet, row, column_widths)
      sheet.add_cell(0, 0, 'change_logs.id').tap do |cell|
        cell.change_font_bold(true)
        cell.change_fill('ddedf3') # color: blue
      end
      sheet.add_cell(0, 1, 'change_logs.created_at').tap do |cell|
        cell.change_font_bold(true)
        cell.change_fill('ddedf3') # color: blue
      end
      sheet.add_cell(0, 2, 'action').tap do |cell|
        cell.change_font_bold(true)
        cell.change_fill('ddedf3') # color: blue
      end
      sheet.add_cell(0, 3, 'id').tap do |cell|
        cell.change_font_bold(true)
        cell.change_fill('ddedf3') # color: blue
      end

      column_widths << 'change_logs.id'.size
      column_widths << 'change_logs.created_at'.size
      column_widths << 'action'.size
      column_widths << 'id'.size

      row.data_column_names.each.with_index(3) do |column_name, i|
        cell = sheet.add_cell(0, i, column_name)
        cell.change_font_bold(true)
        cell.change_fill('ddedf3') # color: blue
        column_widths << column_name.size
      end
    end

    def add_body_rows(sheet, rows, column_widths)
      rows.each.with_index(1) do |row, i|
        column_widths[0] = row.id.to_s.size if column_widths[0] < row.id.to_s.size
        column_widths[2] = row.transaction_id.to_s.size if column_widths[2] < row.transaction_id.to_s.size
        sheet.add_cell(i, 0, row.id)
        sheet.add_cell(i, 1, row.created_at.to_s(:db))
        sheet.add_cell(i, 2, row.action)
        sheet.add_cell(i, 3, row.transaction_id)

        data = row.action == 'DELETE' ? row.before_data : row.after_data

        row.data_column_names.each.with_index(3) do |column_name, j|
          value            = data[column_name].to_s
          column_widths[j] = value.size if column_widths[j] < value.size
          cell_object      = sheet.add_cell(i, j, value)
          if row.action == 'UPDATE' && column_name != 'updated_at' && row.changed_attribute_columns.include?(column_name)
            cell_object.change_fill('ffff00') # color: yellow
          elsif row.action == 'DELETE'
            cell_object.change_fill('d9d9d9') # color: grey
          end
        end
      end
    end

    def add_style(sheet)
      sheet.sheet_data.rows.each.with_index do |row, i|
        row.cells.each do |cell|
          %i[top bottom left right].each do |direction|
            cell.change_border(direction, 'thin')
          end

          cell.change_border(:bottom, 'double') if i.zero?
        end
      end
      sheet.change_row_horizontal_alignment(0, 'center')
    end
  end
end
