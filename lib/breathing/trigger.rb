require 'active_record'
require 'breathing/change_log'

module Breathing
  class Trigger
    attr_reader :model, :log_table_name

    def initialize(model, log_table_name)
      @model          = model
      @log_table_name = log_table_name
    end

    def create
      exists_trigger_names = ActiveRecord::Base.connection.triggers.keys

      trigger_name = "#{log_table_name}_insert_#{model.table_name}"
      create_insert_trigger(trigger_name, model) if exists_trigger_names.exclude?(trigger_name)

      trigger_name = "#{log_table_name}_update_#{model.table_name}"
      create_update_trigger(trigger_name, model) if exists_trigger_names.exclude?(trigger_name)

      trigger_name = "#{log_table_name}_delete_#{model.table_name}"
      create_delete_trigger(trigger_name, model) if exists_trigger_names.exclude?(trigger_name)
    end

    def drop
      trigger_names = %w[insert update delete].map { |action| "#{log_table_name}_#{action}_#{model.table_name}" }

      trigger_names.each do |trigger_name|
        begin
          sql = "DROP TRIGGER IF EXISTS #{trigger_name}"
          if postgresql?
            sql << " ON #{model.table_name} CASCADE;"
            sql << " DROP FUNCTION IF EXISTS #{trigger_name} CASCADE;"
          end
          puts sql
          ActiveRecord::Base.connection.execute(sql)
        rescue StandardError => e
          puts "#{e.message} trigger_name:#{trigger_name}"
        end
      end
    end

    private

    def postgresql?
      ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
    end

    def create_trigger(name)
      puts "CREATE TRIGGER #{name}"
      ActiveRecord::Base.connection.create_trigger(name) # hairtrigger gem
    end

    def create_insert_trigger(trigger_name, model)
      create_trigger(trigger_name).on(model.table_name).after(:insert) do
        <<-SQL
          INSERT INTO #{log_table_name} (created_at, action, table_name, transaction_id, before_data, after_data)
          VALUES (CURRENT_TIMESTAMP, 'INSERT', '#{model.table_name}', NEW.id,
                  '{}',
                  #{row_to_json(model.columns, 'NEW')});
        SQL
      end
    end

    def create_update_trigger(trigger_name, model)
      create_trigger(trigger_name).on(model.table_name).before(:update).of(:updated_at) do
        <<-SQL
          INSERT INTO #{log_table_name} (created_at, action, table_name, transaction_id, before_data, after_data)
              VALUES (CURRENT_TIMESTAMP, 'UPDATE', '#{model.table_name}', NEW.id,
                      #{row_to_json(model.columns, 'OLD')},
                      #{row_to_json(model.columns, 'NEW')});
        SQL
      end
    end

    def create_delete_trigger(trigger_name, model)
      create_trigger(trigger_name).on(model.table_name).after(:delete) do
        <<-SQL
           INSERT INTO #{log_table_name} (created_at, action, table_name, transaction_id, before_data, after_data)
           VALUES (CURRENT_TIMESTAMP, 'DELETE', '#{model.table_name}', OLD.id,
                  #{row_to_json(model.columns, 'OLD')},
                  '{}');
        SQL
      end
    end

    def row_to_json(columns, state)
      if postgresql?
        "row_to_json(#{state}.*)"
      else
        json_object_values = columns.each.with_object([]) do |column, array|
          array << "'#{column.name}'"
          array << "#{state}.#{column.name}"
        end
        "JSON_OBJECT(#{json_object_values.join(',')})"
      end
    end
  end
end
