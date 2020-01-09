class AddFieldsToFabricInfos < ActiveRecord::Migration
  def change
    add_column :fabric_infos, :usd_for_meter, :integer, after: :fabric_type
    add_column :fabric_infos, :fabric_addition, :integer, after: :usd_for_meter
  end
end
