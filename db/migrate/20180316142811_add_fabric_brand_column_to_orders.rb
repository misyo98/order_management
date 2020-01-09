class AddFabricBrandColumnToOrders < ActiveRecord::Migration
  def up
    column_params = { name: 'fabric_brand', label: 'Fabric Brand', order: 76 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'fabric_brand').delete_all
  end
end
