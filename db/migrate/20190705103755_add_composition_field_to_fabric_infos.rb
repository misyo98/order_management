class AddCompositionFieldToFabricInfos < ActiveRecord::Migration
  def change
    add_column :fabric_infos, :fabric_composition, :text
  end
end
