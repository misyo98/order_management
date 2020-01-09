class RenameColumnsInMeasurements < ActiveRecord::Migration
  def change
    rename_column :measurements, :param_id, :category_param_id
    rename_column :measurements, :param_value_id, :category_param_value_id
  end
end
