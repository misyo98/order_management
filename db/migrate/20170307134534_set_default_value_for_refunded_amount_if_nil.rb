class SetDefaultValueForRefundedAmountIfNil < ActiveRecord::Migration
  def change
    LineItem.where(amount_refunded: nil).update_all(amount_refunded: 0)
  end
end
