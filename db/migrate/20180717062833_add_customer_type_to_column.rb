class AddCustomerTypeToColumn < ActiveRecord::Migration
  def up
    column_params = { name: 'customer_type', label: 'Customer Type', order: 111 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'customer_type').delete_all
  end
end
