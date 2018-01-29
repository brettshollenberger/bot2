require "historiographer"

class ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition
  include Historiographer::HistoryMigration
end

class CreateUserUcbClassMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :user_ucb_class_matches do |t|
      t.integer :user_id
      t.integer :ucb_class_id
      t.timestamps
    end

    create_table :user_ucb_class_match_histories do |t|
      t.histories
    end
  end
end
