class CreateUserUcbPreferences < ActiveRecord::Migration[5.1]
  def change
    create_table :user_ucb_preferences do |t|
      t.integer :user_id, null: false
      t.string :class_name, null: false
      t.boolean :active
      t.json :preferences
      t.timestamps
    end
  end
end
