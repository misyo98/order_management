class AddPaidDateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :paid_date, :date, after: :completed_at
  end
end
