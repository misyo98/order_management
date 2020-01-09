class ChangeScaleInFxRates < ActiveRecord::Migration
  def change
    change_column :fx_rates, :usd_gbp, :decimal, precision: 12, scale: 5
    change_column :fx_rates, :usd_sgd, :decimal, precision: 12, scale: 5
    change_column :fx_rates, :usd_eur, :decimal, precision: 12, scale: 5
  end
end
