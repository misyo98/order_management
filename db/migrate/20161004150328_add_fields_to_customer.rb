class AddFieldsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :username,      :string,  after: :email
    add_column :customers, :avatar,        :string , after: :username
    add_column :customers, :role,          :integer, after: :avatar,        default: 0
    add_column :customers, :last_order_id, :integer, after: :role
    add_column :customers, :orders_count,  :integer, after: :last_order_id, default: 0
    add_column :customers, :total_spent,   :decimal, after: :orders_count,  precision: 8, scale: 2, default: 0
  end
end
