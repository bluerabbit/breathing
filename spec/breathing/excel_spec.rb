require 'spec_helper'

describe Breathing::Excel do
  describe '#create' do
    before { Breathing::Installer.new.install }
    after { Breathing::Installer.new.uninstall }

    it do
      user = User.create!(name: 'a', age: 20)
      user.update!(age: 21)
      user.destroy!
      expect(Breathing::ChangeLog.count).to eq(3)

      dept = Department.create!(name: 'a')
      dept.update!(name: 'b')

      Tempfile.open(["tmp", ".xlsx"]) do |file|
        Breathing::Excel.new.create(file_name: file.path)
        workbook = RubyXL::Parser.parse(file.path)
        expect(workbook.sheets.size).to eq(2)
        expect(workbook.sheets[0].name).to eq("departments")
        expect(workbook.sheets[1].name).to eq("users")
        department_sheet = workbook.worksheets[0]
        expect(department_sheet.sheet_data.size).to eq(Breathing::ChangeLog.where(table_name: :departments).count + 1)
        user_sheet = workbook.worksheets[1]
        expect(user_sheet.sheet_data.size).to eq(Breathing::ChangeLog.where(table_name: :users).count + 1)
      end
    end
  end
end
