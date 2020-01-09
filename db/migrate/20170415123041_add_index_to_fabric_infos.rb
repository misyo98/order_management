class AddIndexToFabricInfos < ActiveRecord::Migration
  def change
    add_index :fabric_infos, :fabric_code
  end
end
