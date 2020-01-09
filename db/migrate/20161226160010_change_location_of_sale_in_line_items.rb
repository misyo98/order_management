class ChangeLocationOfSaleInLineItems < ActiveRecord::Migration
  def change
    rename_column :line_items, :location_of_sale, :sales_location_id
    change_column :line_items, :sales_location_id, :integer
  end
end
