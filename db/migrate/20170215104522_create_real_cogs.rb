class CreateRealCogs < ActiveRecord::Migration
  def change
    create_table :real_cogs do |t|
      t.string :manufacturer_id
      t.string :order_number
      t.string :name
      t.string :country
      t.string :product_rc
      t.string :construction
      t.decimal :meters, precision: 5, scale: 2
      t.string :fabric
      t.string :product_group
      t.decimal :cogs_rc_usd, precision: 5, scale: 2
      t.date :order_date
      t.date :deal_date

      t.timestamps null: false
    end
  end
end
