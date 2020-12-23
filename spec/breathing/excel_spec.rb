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
        expect(workbook.sheets[0].name).to eq('users')
        user_sheet = workbook.worksheets[0]
        expect(user_sheet.sheet_data.size).to eq(Breathing::ChangeLog.where(table_name: :users).count + 1)
      end
    end

    it 'multi sheets' do
      User.create!(name: 'a', age: 20)
      Department.create!(name: 'a')

      Tempfile.open(['tmp', '.xlsx']) do |file|
        Breathing::Excel.new.create(file_name: file.path)
        workbook = RubyXL::Parser.parse(file.path)
        expect(workbook.sheets.map(&:name)).to eq(%w[departments users])
      end
    end
  end
end
