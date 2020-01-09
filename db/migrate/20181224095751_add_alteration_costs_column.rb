class AddAlterationCostsColumn < ActiveRecord::Migration
  def up
    column_params = { name: 'alteration_costs', label: 'Alteration Costs', order: 116 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'alteration_costs').delete_all
  end
end
