class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.string :type_product
      t.string :status
      t.string :permalink
      t.string :sku
      t.decimal :price, precision: 6, scale: 2
      t.decimal :regular_price, precision: 6, scale: 2
      t.decimal :sale_price, precision: 6, scale: 2
      t.integer :total_sales

      t.timestamps null: false
    end
  end
end
