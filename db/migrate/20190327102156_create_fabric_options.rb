class CreateFabricOptions < ActiveRecord::Migration
  def change
    create_table :fabric_options do |t|
      t.references :fabric_category, index: true, foreign_key: { on_delete: :nullify }
      t.references :fabric_tab, index: true, foreign_key: { on_delete: :nullify }
      t.string :title
      t.integer :order
      t.integer :button_type
      t.string :placeholder
      t.integer :outfitter_selection
      t.integer :tuxedo
      t.integer :premium
      t.integer :fusible
      t.integer :manufacturer

      t.timestamps null: false
    end
  end
end
