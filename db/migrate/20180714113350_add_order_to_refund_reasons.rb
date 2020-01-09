class AddOrderToRefundReasons < ActiveRecord::Migration
  def change
    add_column :refund_reasons, :order, :integer, default: 0
  end
end
