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
      trigger_name = "#{log_table_name}_insert_#{model.table_name}"
      unless exists?(trigger_name)
        puts "CREATE TRIGGER #{trigger_name}"
        ActiveRecord::Base.connection.execute <<-SQL
        CREATE TRIGGER #{trigger_name}
        AFTER INSERT
        ON #{model.table_name}
        FOR EACH ROW
        BEGIN
          INSERT INTO #{log_table_name} (`action`, `table_name`, `transaction_id`, `before_data`, `after_data`, `created_at`)
          VALUES ('INSERT', '#{model.table_name}', NEW.id,
                  JSON_OBJECT(),
                  JSON_OBJECT(#{json_object_values(model.columns, 'NEW')}),
                  CURRENT_TIMESTAMP);
        END;
        SQL
      end

      trigger_name = "#{log_table_name}_update_#{model.table_name}"
      unless exists?(trigger_name)
        puts "CREATE TRIGGER #{trigger_name}"
        ActiveRecord::Base.connection.execute <<-SQL
        CREATE TRIGGER #{trigger_name}
        BEFORE UPDATE
        ON #{model.table_name}
        FOR EACH ROW
        BEGIN
          IF (OLD.updated_at != NEW.updated_at) THEN
              INSERT INTO #{log_table_name} (`action`, `table_name`, `transaction_id`, `before_data`, `after_data`, `created_at`)
              VALUES ('UPDATE', '#{model.table_name}', NEW.id,
                      JSON_OBJECT(#{json_object_values(model.columns, 'OLD')}),
                      JSON_OBJECT(#{json_object_values(model.columns, 'NEW')}),
                      CURRENT_TIMESTAMP);
          end if;
        END;
        SQL
      end

      trigger_name = "#{log_table_name}_delete_#{model.table_name}"
      unless exists?(trigger_name)
        puts "CREATE TRIGGER #{trigger_name}"
        ActiveRecord::Base.connection.execute <<-SQL
        CREATE TRIGGER #{trigger_name}
        AFTER DELETE
        ON #{model.table_name}
        FOR EACH ROW
        BEGIN
          INSERT INTO #{log_table_name} (`action`, `table_name`, `transaction_id`, `before_data`, `after_data`, `created_at`)
          VALUES ('DELETE', '#{model.table_name}', OLD.id,
                  JSON_OBJECT(#{json_object_values(model.columns, 'OLD')}),
                  JSON_OBJECT(),
                  CURRENT_TIMESTAMP);
        END;
        SQL
      end
    end

    def drop
      %w[insert update delete].each do |action|
        trigger_name = "#{log_table_name}_#{action}_#{model.table_name}"
        next unless exists?(trigger_name)

        begin
          sql = "DROP TRIGGER #{trigger_name}"
          puts sql
          ActiveRecord::Base.connection.execute(sql)
        rescue StandardError => e
          puts "#{e.message} trigger_name:#{trigger_name}"
        end
      end
    end

    private

    def exists?(trigger_name)
      @trigger_names ||= ActiveRecord::Base.connection.select_rows('SHOW TRIGGERS').map { |row| row.first }
      @trigger_names.include?(trigger_name)
    end

    def json_object_values(columns, state)
      columns.each.with_object([]) do |column, array|
        array << "'#{column.name}'"
        array << "#{state}.#{column.name}"
      end.join(',')
    end
  end
end
