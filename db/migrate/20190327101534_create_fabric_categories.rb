class CreateFabricCategories < ActiveRecord::Migration
  def change
    create_table :fabric_categories do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
