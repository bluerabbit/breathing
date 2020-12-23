require 'active_record'

module Breathing
  class ChangeLog < ActiveRecord::Base
    def changed_attribute_columns
      before_data.each.with_object([]) do |(column, value), columns|
        columns << column if after_data[column] != value
      end
    end

    def data_column_names
      names = before_data.keys.present? ? before_data.keys : after_data.keys
      names.reject { |name| name == 'id' }
    end

    def data
      action == 'DELETE' ? before_data : after_data
    end

    def data_attributes
      data_column_names.each.with_object('change_logs.id'         => id,
                                         'change_logs.created_at' => created_at.to_s(:db),
                                         'action'                 => action,
                                         'id'                     => transaction_id) do |name, hash|
        hash[name] = data[name]
      end
    end

    def diff
      return nil if action != 'UPDATE'

      changed_attribute_columns.each.with_object({}) do |column_name, diff_hash|
        diff_hash[column_name] = {before_data[column_name] => after_data[column_name]}
      end
    end

    def attributes_for_excel
      {
        'change_logs.id' => id,
        'created_at'     => created_at.to_s(:db),
        'table_name'     => table_name,
        'action'         => action,
        'id'             => transaction_id,
        'diff'           => diff.to_s,
        'before_data'    => before_data.to_s,
        'after_data'     => after_data.to_s,
      }
    end
  end
end
