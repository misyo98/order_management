class AddOrderToFabricInfosAndFabricOptionValues < ActiveRecord::Migration
  def change
    add_column :fabric_infos, :order, :integer
  end
end
