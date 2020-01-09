class AddOccasionDateColumnToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'occasion_date_field', label: 'Occasion Date', order: 70 }

    add_column :line_items, :occasion_date, :date, after: :delivery_appointment_date

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :occasion_date

    Column.where(columnable_type: 'LineItemScope', name: 'occasion_date_field').delete_all
  end
end
