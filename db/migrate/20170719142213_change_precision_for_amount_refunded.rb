class ChangePrecisionForAmountRefunded < ActiveRecord::Migration
  def change
    change_column :line_items, :amount_refunded, :decimal, precision:8, scale: 2
  end
end
