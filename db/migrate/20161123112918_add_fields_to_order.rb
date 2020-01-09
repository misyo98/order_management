class AddFieldsToOrder < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.column :completed_at, :datetime
      t.column :status, :integer
      t.column :currency, :string
      t.column :total, :integer #save total in cents
      t.column :subtotal, :integer #save total in cents
      t.column :total_line_items_quantity, :integer
      t.column :total_tax, :integer #save total in cents
      t.column :total_shipping, :integer #save total in cents
      t.column :cart_tax, :integer #save total in cents
      t.column :shipping_tax, :integer #save total in cents
      t.column :total_discount, :integer #save total in cents
      t.column :shipping_methods, :string 
      t.column :note, :string 
      t.column :customer_ip, :string 
      t.column :customer_user_agent, :string 
      t.column :view_order_url, :string 
      t.column :shipping_lines, :text 
      t.column :tax_lines, :text 
      t.column :fee_lines , :text 
      t.column :coupon_lines, :text 
    end
  end
end
