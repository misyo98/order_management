class AddAccountingFieldsToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :real_inbound_ship_cost, :decimal, scale: 2, precision: 5, after: :courier_company_id
    add_column :line_items, :real_duty, :decimal, scale: 2, precision: 5, after: :real_inbound_ship_cost 
  end
end
