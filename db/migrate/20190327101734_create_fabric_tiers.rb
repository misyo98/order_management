class CreateFabricTiers < ActiveRecord::Migration
  def change
    create_table :fabric_tiers do |t|
      t.references :fabric_category, index: true, foreign_key: { on_delete: :cascade }
      t.string :title
      t.decimal :price, precision: 8, scale: 2
      t.integer :order

      t.timestamps null: false
    end
  end
end
