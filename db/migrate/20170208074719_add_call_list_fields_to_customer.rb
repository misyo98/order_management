class AddCallListFieldsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :status, :text, after: :total_spent
    add_column :customers, :last_contact_date, :date, after: :status
  end
end
