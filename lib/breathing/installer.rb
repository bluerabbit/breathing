require 'active_record'
require 'breathing'
require 'breathing/trigger'
require 'breathing/change_log'

module Breathing
  class UnsupportedError < StandardError; end

  class Installer
    def install
      raise Breathing::UnsupportedError, "Version MySQL 5.6 is not supported." unless database_supported_version?

      create_log_table

      models.each do |model|
        column_names = model.columns.map(&:name)
        if column_names.include?('id') && column_names.include?('updated_at')
          Breathing::Trigger.new(model, log_table_name).create
        end
      end
    end

    def uninstall
      drop_log_table
      models.each { |model| Breathing::Trigger.new(model, log_table_name).drop }
    end

    private

    def database_supported_version?
      connection = ActiveRecord::Base.connection
      connection.adapter_name == "PostgreSQL" || (connection.adapter_name == 'Mysql2' && connection.raw_connection.info[:version].to_f >= 5.7)
    end

    def log_table_name
      Breathing::ChangeLog.table_name
    end

    def create_log_table(table_name: log_table_name)
      ActiveRecord::Schema.define version: 0 do
        create_table table_name, if_not_exists: true do |t|
          t.datetime :created_at,     null: false, index: true
          t.string   :table_name,     null: false
          t.string   :action,         null: false
          t.string   :transaction_id, null: false
          t.json     :before_data,    null: false
          t.json     :after_data,     null: false

          t.index %w[table_name transaction_id]
        end
      end
    end

    def drop_log_table
      puts "DROP TABLE #{log_table_name}"
      ActiveRecord::Base.connection.drop_table(log_table_name, if_exists: true)
    end

    def models
      ignores = %w[schema_migrations ar_internal_metadata] << log_table_name

      ActiveRecord::Base.connection.tables.each do |table_name|
        next if ignores.include?(table_name) || Object.const_defined?(table_name.classify)

        eval <<-EOS
          class #{table_name.classify} < ActiveRecord::Base
            self.table_name = :#{table_name}
          end
        EOS
      end

      ActiveRecord::Base.descendants.reject(&:abstract_class).reject { |m| ignores.include? m.table_name }
    end
  end
end
