require "historiographer"

class ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition
  include Historiographer::HistoryMigration
end

class UcbClass < ActiveRecord::Migration[5.1]
  def change
    create_table :ucb_classes do |t|
      t.string :level, null: false
      t.integer :start_hour, null: false
      t.integer :start_minute, null: false
      t.integer :end_hour, null: false
      t.integer :end_minute, null: false
      t.string :teacher, null: false
      t.boolean :available
      t.string :registration_url
      t.integer :ucb_id, null: false
      t.string :human_dates
      t.timestamps
      t.index [:level, :teacher]
      t.index :ucb_id
    end

    create_table :ucb_class_histories do |t|
      t.histories
    end
  end
end
