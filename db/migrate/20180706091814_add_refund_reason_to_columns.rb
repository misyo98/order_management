class AddRefundReasonToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'refund_reason', label: 'Refund Reason', order: 79 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'refund_reason').delete_all
  end
end
