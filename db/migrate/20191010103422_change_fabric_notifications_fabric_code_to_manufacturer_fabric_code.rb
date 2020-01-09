class ChangeFabricNotificationsFabricCodeToManufacturerFabricCode < ActiveRecord::Migration
  def change
    add_column :fabric_notifications, :manufacturer_fabric_code, :string, after: :fabric_code
    add_column :fabric_notifications, :fabric_book_title, :string, after: :manufacturer_fabric_code
    add_column :fabric_notifications, :fabric_brand_title, :string, after: :fabric_book_title
  end
end
