require 'spec_helper'

describe Breathing do
  it 'has a version number' do
    expect(Breathing::VERSION).not_to be nil
  end

  describe 'change_logs' do
    before { Breathing::Installer.new.install }

    after do
      Breathing::Installer.new.uninstall if ActiveRecord::Base.connection == "Mysql2"
    end

    it do
      expect(Breathing::ChangeLog.count).to eq(0)

      # INSERT
      user = User.create!(name: 'a', age: 20)
      expect(Breathing::ChangeLog.count).to eq(1)

      log = Breathing::ChangeLog.where(table_name: user.class.table_name, transaction_id: user.id).last
      expect(log.before_data).to eq({})
      expect(log.after_data['name']).to eq('a')
      expect(log.after_data['age']).to eq(20)

      # UPDATE
      user.update!(age: 21)
      expect(Breathing::ChangeLog.count).to eq(2)

      log = Breathing::ChangeLog.where(table_name: user.class.table_name, transaction_id: user.id).last
      expect(log.before_data['age']).to eq(20)
      expect(log.after_data['age']).to eq(21)
      expect(log.before_data['name']).to eq(log.after_data['name'])
      expect(log.changed_attribute_columns).to eq(%w[age updated_at])

      # DELETE
      user.destroy!
      expect(Breathing::ChangeLog.count).to eq(3)
      log = Breathing::ChangeLog.where(table_name: user.class.table_name, transaction_id: user.id).last
      expect(log.before_data['name']).to eq('a')
      expect(log.after_data).to eq({})
    end
  end
end
