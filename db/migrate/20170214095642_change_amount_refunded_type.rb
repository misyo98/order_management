class ChangeAmountRefundedType < ActiveRecord::Migration
  def change
    change_column :line_items, :amount_refunded, :decimal, precision: 5, scale: 2, default: 0
  end
end
