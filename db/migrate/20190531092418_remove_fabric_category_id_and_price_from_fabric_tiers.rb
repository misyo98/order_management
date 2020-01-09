class RemoveFabricCategoryIdAndPriceFromFabricTiers < ActiveRecord::Migration
  def up
    remove_reference :fabric_tiers, :fabric_category, index: true, foreign_key: { on_delete: :cascade }
    remove_column :fabric_tiers, :price
  end
  
  def down
    add_reference :fabric_tiers, :fabric_category, index: true, foreign_key: { on_delete: :cascade }, after: :id
    add_column :fabric_tiers, :price, :json, after: :title
  end
end
