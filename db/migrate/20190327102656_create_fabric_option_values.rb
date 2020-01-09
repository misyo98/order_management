class CreateFabricOptionValues < ActiveRecord::Migration
  def change
    create_table :fabric_option_values do |t|
      t.references :fabric_option, index: true, foreign_key: { on_delete: :cascade }
      t.string :title
      t.integer :order
      t.text :image_url
      t.text :price

      t.timestamps null: false
    end
  end
end
