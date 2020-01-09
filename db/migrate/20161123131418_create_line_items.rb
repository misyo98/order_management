class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :subtotal
      t.integer :subtotal_tax
      t.integer :total
      t.integer :total_tax
      t.integer :price
      t.integer :quantity
      t.string :tax_class
      t.string :name
      t.integer :product_id
      t.string :sku
      t.text :meta
      t.text :variations

      t.timestamps null: false
    end
  end
end
