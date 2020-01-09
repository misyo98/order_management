class CreateEnabledFabricCategories < ActiveRecord::Migration
  def change
    create_table :enabled_fabric_categories do |t|
      t.references :fabric_info, index: true, foreign_key: { on_delete: :cascade }
      t.references :fabric_category, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps null: false
    end
  end
end
