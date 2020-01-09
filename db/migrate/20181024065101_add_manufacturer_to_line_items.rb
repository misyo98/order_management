class AddManufacturerToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :manufacturer, :integer, default: 0

    LineItem.update_all(manufacturer: 1)

    column_params = { name: 'manufacturer', label: 'Manufacturer', order: 114 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :manufacturer

    Column.where(columnable_type: 'LineItemScope', name: 'manufacturer').delete_all
  end
end
