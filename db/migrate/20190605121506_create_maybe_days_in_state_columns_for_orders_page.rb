class CreateMaybeDaysInStateColumnsForOrdersPage < ActiveRecord::Migration
  def up
    LineItemScope.find_each do |scope|
      scope.columns.create!(name: 'maybe_days_in_state_field', label: 'Days in current state', order: 124, columnable_type: 'LineItem')
    end
  end

  def down
    Column.where(name: 'maybe_days_in_state_field').destroy_all
  end
end
