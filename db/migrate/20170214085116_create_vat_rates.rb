class CreateVatRates < ActiveRecord::Migration
  def change
    create_table :vat_rates do |t|
      t.string :shipping_country
      t.integer :rate

      t.timestamps null: false
    end
  end
end
