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

        rows = Breathing::ChangeLog.where(table_name: table_name).where('id >= ?', id).order(:id)

        if first_row = rows.first
          add_header_row(sheet, first_row)
        end
        add_body_rows(sheet, rows)
        add_style(sheet)
      end

      @workbook.write(file_name)
    end

    private

    def add_header_row(sheet, row)
      sheet.add_cell(0, 0, 'change_logs.id').change_font_bold(true)
      sheet.add_cell(0, 1, 'action').change_font_bold(true)
      sheet.add_cell(0, 2, 'id').change_font_bold(true)
      row.data_column_names.each.with_index(3) do |column_name, i|
        sheet.add_cell(0, i, column_name).change_font_bold(true)
      end
    end

    def add_body_rows(sheet, rows)
      rows.each.with_index(1) do |row, i|
        sheet.add_cell(i, 0, row.id)
        sheet.add_cell(i, 1, row.action)
        sheet.add_cell(i, 2, row.transaction_id)
        row.data_column_names.each.with_index(3) do |column_name, j|
          data        = row.action == 'DELETE' ? row.before_data : row.after_data
          cell_object = sheet.add_cell(i, j, data[column_name])
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

          cell.change_border(:bottom, 'medium') if i.zero?
        end
      end
      sheet.change_row_horizontal_alignment(0, 'center')
    end
  end
end
