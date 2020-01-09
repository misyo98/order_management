class RenameManufacturerIdToManufacturerCode < ActiveRecord::Migration
  def change
    rename_column :alteration_infos, :manufacturer_id, :manufacturer_code
  end
end
