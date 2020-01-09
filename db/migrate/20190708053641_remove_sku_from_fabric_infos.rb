class RemoveSkuFromFabricInfos < ActiveRecord::Migration
  def change
    remove_column :fabric_infos, :sku, :string
  end
end
