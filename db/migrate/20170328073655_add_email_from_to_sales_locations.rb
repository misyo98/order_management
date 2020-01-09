class AddEmailFromToSalesLocations < ActiveRecord::Migration
  def change
    add_column :sales_locations, :email_from, :string, after: :showroom_address
  end
end
