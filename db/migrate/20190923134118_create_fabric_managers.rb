class CreateFabricManagers < ActiveRecord::Migration
  def change
    create_table :fabric_managers do |t|
      t.string :manufacturer_fabric_code, index: true
      t.references :fabric_brand, index: true, foreign_key: true
      t.references :fabric_book, index: true, foreign_key: true
      t.integer :status
      t.string :estimated_restock_date

      t.timestamps null: false
    end
  end
end
