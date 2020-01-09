class UpdateLineItemsScopeWithCoupon < ActiveRecord::Migration
  def up
    column_params = { name: 'coupons', label: 'Coupons', order: 75 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'coupons').delete_all
  end
end
