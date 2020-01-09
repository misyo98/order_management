class AddColumnsToSalesLocations < ActiveRecord::Migration
  def change
    add_column :sales_locations, :showroom_address, :string, after: :name
    add_column :sales_locations, :delivery_calendar_link, :string, after: :showroom_address
  end
end
