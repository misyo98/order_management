class CreateFxRates < ActiveRecord::Migration
  def change
    create_table :fx_rates do |t|
      t.decimal :usd_gbp, precision: 5, scale: 2
      t.decimal :usd_sgd, precision: 5, scale: 2
      t.decimal :usd_eur, precision: 5, scale: 2
      t.date :valid_from

      t.timestamps null: false
    end
  end
end
