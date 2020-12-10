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
  end
end