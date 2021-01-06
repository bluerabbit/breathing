require 'spec_helper'

describe Breathing::Excel do
  describe '#create' do
    before { Breathing::Installer.new.install }
    after do
      Breathing::Installer.new.uninstall if ActiveRecord::Base.connection.adapter_name == "Mysql2"
    end

    it do
      user = User.create!(name: 'a', age: 20)
      user.update!(age: 21)
      user.destroy!
      expect(Breathing::ChangeLog.count).to eq(3)

      Tempfile.open(['tmp', '.xlsx']) do |file|
        Breathing::Excel.new.create(file_name: file.path)
        workbook = RubyXL::Parser.parse(file.path)
        expect(workbook.sheets.map(&:name)).to eq(%w[change_logs users])
        user_sheet = workbook.worksheets.last
        expect(user_sheet.sheet_data.size).to eq(Breathing::ChangeLog.where(table_name: :users).count + 1)
      end
    end

    it 'multi sheets' do
      department = Department.create!(name: 'a')

      user = User.create!(name: 'a', age: 20, department_id: department.id)
      user.update!(age: 21)
      user.destroy!

      Tempfile.open(['tmp', '.xlsx']) do |file|
        Breathing::Excel.new.create(file_name: file.path)
        workbook = RubyXL::Parser.parse(file.path)
        expect(workbook.sheets.map(&:name)).to eq(%w[change_logs departments users])
        change_logs_sheet = workbook.worksheets.first

        expect(change_logs_sheet.sheet_data.size).to eq(Breathing::ChangeLog.count + 1)
      end
    end
  end
end
