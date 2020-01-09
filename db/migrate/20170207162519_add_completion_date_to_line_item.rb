class AddCompletionDateToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :completion_date, :date, after: :next_appointment_date
  end
end
