class RemoveOrderFromFabricInfos < ActiveRecord::Migration
  def change
    remove_column :fabric_infos, :order, :integer
  end
end
