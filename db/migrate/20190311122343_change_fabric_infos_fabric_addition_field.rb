class ChangeFabricInfosFabricAdditionField < ActiveRecord::Migration
  def up
    change_column :fabric_infos, :fabric_addition, :decimal, precision: 8, scale: 2
  end

  def down
    change_column :fabric_infos, :fabric_addition, :integer
  end
end
