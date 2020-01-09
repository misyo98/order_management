class ChangeRateType < ActiveRecord::Migration
  def change
    change_column :vat_rates, :rate, :decimal, precision: 5, scale: 2
  end
end
