class AddFabricOrderedColumnToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :ordered_fabric, :boolean

    column_params = { name: 'ordered_fabric', label: 'Fabric ordered?', order: 119 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :ordered_fabric

    Column.where(columnable_type: 'LineItemScope', name: 'ordered_fabric').delete_all
  end
end
