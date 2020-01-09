class AddEstimatedDeliveryDateToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'estimated_delivery_date', label: 'Estimated Delivery Date', order: 62 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'estimated_delivery_date').delete_all
  end
end
