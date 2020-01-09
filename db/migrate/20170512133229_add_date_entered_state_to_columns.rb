class AddDateEnteredStateToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'date_entered_state', label: 'Date Entered State', order: 58 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'date_entered_state').delete_all
  end
end
