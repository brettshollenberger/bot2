class AddCityToUserUcbPreferences < ActiveRecord::Migration[5.1]
  def change
    add_column :user_ucb_preferences, :city, :string
  end
end
