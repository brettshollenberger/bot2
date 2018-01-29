class UcbClassDate < ActiveRecord::Migration[5.1]
  def change
    create_table :ucb_class_date do |t|
      t.integer :ucb_class_id, null: false
      t.datetime :starts_at
      t.timestamps
    end
  end
end
