class CreateUcbClassDates < ActiveRecord::Migration[5.1]
  def change
    create_table :ucb_class_dates do |t|
      t.integer :ucb_class_id
      t.timestamp :starts_at
      t.integer :start_hour
      t.integer :start_minute
      t.integer :end_hour
      t.integer :end_minute

      t.timestamps
    end
  end
end
