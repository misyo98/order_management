class ChangeFabricInfosUsdForMeterField < ActiveRecord::Migration
  def up
    change_column :fabric_infos, :usd_for_meter, :decimal, precision: 8, scale: 2
  end

  def down
    change_column :fabric_infos, :usd_for_meter, :integer
  end
end
