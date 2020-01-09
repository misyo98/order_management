class AddFieldsToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :comment, :text, after: :variations
    add_column :line_items, :sales_person_id, :integer, after: :comment
    add_column :line_items, :location_of_sale, :string, after: :sales_person_id
    add_column :line_items, :fabric_code, :string, after: :location_of_sale
    add_column :line_items, :fabric_status, :integer, after: :fabric_code
    add_column :line_items, :fabric_ordered, :date, after: :fabric_status
    add_column :line_items, :fabric_received, :date, after: :fabric_ordered
    add_column :line_items, :manufacturer_order_status, :integer, after: :fabric_received
    add_column :line_items, :manufacturer_order_number, :integer, after: :manufacturer_order_status
    add_column :line_items, :tracking_number, :string, after: :manufacturer_order_number
    add_column :line_items, :shipped_date, :date, after: :tracking_number
    add_column :line_items, :shipment_received_date, :date, after: :shipped_date
    add_column :line_items, :next_appointment, :date, after: :shipment_received_date
    add_column :line_items, :complete, :boolean, after: :next_appointment
    add_column :line_items, :amount_refunded, :integer, after: :complete
  end
end
