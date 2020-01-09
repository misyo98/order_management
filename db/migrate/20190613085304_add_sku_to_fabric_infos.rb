class AddSkuToFabricInfos < ActiveRecord::Migration
  def change
    add_column :fabric_infos, :sku, :string, after: :manufacturer_fabric_code
  end
end
