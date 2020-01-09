class AddOrderToFabricTabs < ActiveRecord::Migration
  def change
    add_column :fabric_tabs, :order, :integer, after: :title
  end
end
