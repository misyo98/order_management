class AddColumnsToFabricOptionValues < ActiveRecord::Migration
  def change
    add_column :fabric_option_values, :premium, :integer, after: :price
    add_column :fabric_option_values, :manufacturer, :integer, after: :premium
  end
end
