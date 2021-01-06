require 'active_record'
require 'breathing'

ActiveRecord::Base.establish_connection(
  YAML.load(ERB.new(File.read('spec/database.yml')).result)["test_#{ENV['DB'] || 'mysql'}"]
)

ActiveRecord::Schema.define version: 0 do
  create_table :users, force: true do |t|
    t.references :department, foreign_key: false
    t.string :name, null: false
    t.integer :age, null: false
    t.timestamps null: false
  end

  create_table :departments, force: true do |t|
    t.string :name, null: false
    t.timestamps null: false
  end

  add_foreign_key :users, :departments
end

class User < ActiveRecord::Base
end

class Department < ActiveRecord::Base
end
