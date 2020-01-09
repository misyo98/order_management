class AddSelfMeasuredColumn < ActiveRecord::Migration
  def up
    column_params = { name: 'self_measured', label: 'Self Measured', order: 77 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'self_measured').delete_all
  end
end
