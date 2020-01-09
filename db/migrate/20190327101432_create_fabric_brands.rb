class CreateFabricBrands < ActiveRecord::Migration
  def change
    create_table :fabric_brands do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
