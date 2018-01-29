class CreateUcbClassHolds < ActiveRecord::Migration[5.1]
  def change
    create_table :ucb_class_holds do |t|
      t.integer :user_id
      t.string :hold_url
      t.integer :ucb_class_id
      t.timestamps
    end
  end
end
