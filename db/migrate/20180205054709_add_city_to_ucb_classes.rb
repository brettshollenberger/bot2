class AddCityToUcbClasses < ActiveRecord::Migration[5.1]
  def change
    add_column :ucb_classes, :city, :string
    add_index :ucb_classes, [:level, :city]
  end
end
