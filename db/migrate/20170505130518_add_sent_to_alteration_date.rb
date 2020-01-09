class AddSentToAlterationDate < ActiveRecord::Migration
  def up
    add_column :line_items, :sent_to_alteration_date, :date, after: :next_appointment_date

    column_params = { name: 'sent_to_alteration_date_field', label: 'Date sent to alterations tailor', order: 57 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :sent_to_alteration_date
    
    Column.where(columnable_type: 'LineItemScope', name: 'sent_to_alteration_date_field').delete_all
  end
end
