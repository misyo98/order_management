class ChangePriceFieldForFabricOptionValuesAndFabricTiers < ActiveRecord::Migration
  def up
    change_column :fabric_option_values, :price, :json
    change_column :fabric_tiers, :price, :json
  end
  
  def down
    change_column :fabric_option_values, :price, :text
    change_column :fabric_tiers, :price, :text
  end
end
