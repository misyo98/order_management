class SetDefaultValueForRefundedAmount < ActiveRecord::Migration
  def up
    change_column_default :line_items, :amount_refunded, 0
  end

  def down
  end
end
