class AddDeliveryAppointmentDateFieldToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'delivery_appointment_date_field', label: 'Delivery Appointment Date', order: 60 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'delivery_appointment_date_field').delete_all
  end
end
