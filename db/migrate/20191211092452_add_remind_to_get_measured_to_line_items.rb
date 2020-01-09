class AddRemindToGetMeasuredToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :remind_to_get_measured, :date

    column_params = { name: 'remind_to_get_measured', label: 'Remind to get measured', order: 135 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :remind_to_get_measured

    Column.where(columnable_type: 'LineItemScope', name: 'remind_to_get_measured').delete_all
  end
end
