class ChangeLineItemColumns < ActiveRecord::Migration
  def change
    rename_column :line_items, :fabric_code, :fabric_code_value
    rename_column :line_items, :fabric_status, :fabric_status_value
    rename_column :line_items, :manufacturer_order_status, :m_order_status
    rename_column :line_items, :manufacturer_order_number, :m_order_number
    rename_column :line_items, :next_appointment, :next_appointment_date
  end
end
