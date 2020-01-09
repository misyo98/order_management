class ChangeFabricTiersPriceColumn < ActiveRecord::Migration
  def up
    change_column :fabric_tiers, :price, :text
  end
  
  def down
    change_column :fabric_tiers, :price, :decimal, precision: 8, scale: 2
  end
end
