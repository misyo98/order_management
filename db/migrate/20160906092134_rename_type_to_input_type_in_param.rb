class RenameTypeToInputTypeInParam < ActiveRecord::Migration
  def change
    rename_column :params, :type, :input_type
  end
end
