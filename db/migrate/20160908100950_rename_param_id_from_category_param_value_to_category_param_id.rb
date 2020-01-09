class RenameParamIdFromCategoryParamValueToCategoryParamId < ActiveRecord::Migration
  def change
    rename_column :category_param_values, :param_id, :category_param_id
  end
end
