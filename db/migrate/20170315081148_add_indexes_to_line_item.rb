class AddIndexesToLineItem < ActiveRecord::Migration
  def change
    add_index :line_items, :order_id
    add_index :line_items, :product_id
    add_index :line_items, :sales_person_id
    add_index :line_items, :sales_location_id
    add_index :line_items, :alteration_tailor_id
    add_index :line_items, :courier_company_id
    add_index :line_items, :fabric_code_value
    add_index :line_items, :m_order_number
  end
end
