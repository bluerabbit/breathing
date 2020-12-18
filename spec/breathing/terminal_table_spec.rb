require 'spec_helper'

describe Breathing::TerminalTable do
  describe '#render' do
    before { Breathing::Installer.new.install }
    after do
      Breathing::Installer.new.uninstall if ActiveRecord::Base.connection.adapter_name == "Mysql2"
    end

    it do
      user = User.create!(name: 'a', age: 20)
      user.update!(age: 21)
      user.destroy!
      expect(Breathing::ChangeLog.count).to eq(3)

      table = Breathing::TerminalTable.new(:users)
      puts table.render(id: 1)

      expect(table.rows.size).to eq(3)
    end
  end
end
