class AddDeliveryAppointmentDateToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :delivery_appointment_date, :date, after: :next_appointment_date
  end
end
