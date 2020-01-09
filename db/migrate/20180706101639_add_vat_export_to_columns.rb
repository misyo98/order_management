class AddVatExportToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'vat_export_field', label: 'VAT Export', order: 80 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'vat_export_field').delete_all
  end
end
