class AddGarmentFitToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'garment_fit', label: 'Garment Fit', order: 71 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'garment_fit').delete_all
  end
end
