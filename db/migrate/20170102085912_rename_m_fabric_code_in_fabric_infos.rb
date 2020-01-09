class RenameMFabricCodeInFabricInfos < ActiveRecord::Migration
  def change
    rename_column :fabric_infos, :m_fabric_code, :manufacturer_fabric_code
  end
end
