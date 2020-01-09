class AddNonAlteredItemsToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'non_altered_items_field', label: 'Non-altered Items', order: 70 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'non_altered_items_field').delete_all
  end
end
