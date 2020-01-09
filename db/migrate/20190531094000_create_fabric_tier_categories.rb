class CreateFabricTierCategories < ActiveRecord::Migration
  def change
    create_table :fabric_tier_categories do |t|
      t.references :fabric_tier, index: true, foreign_key: true
      t.references :fabric_category, index: true, foreign_key: true
      t.json :price

      t.timestamps null: false
    end
  end
end
