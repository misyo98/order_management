class ChangeFabricTypeType < ActiveRecord::Migration
  def change
    change_column :fabric_infos, :fabric_type, :integer
  end
end
