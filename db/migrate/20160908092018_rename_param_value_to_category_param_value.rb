class RenameParamValueToCategoryParamValue < ActiveRecord::Migration
  def change
    rename_table :param_values, :category_param_values
  end
end
