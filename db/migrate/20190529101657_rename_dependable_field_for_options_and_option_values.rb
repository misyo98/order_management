class RenameDependableFieldForOptionsAndOptionValues < ActiveRecord::Migration
  def up
    rename_column :fabric_options, :dependable_id, :depends_on_option_value_id
    rename_column :fabric_option_values, :dependable_id, :depends_on_option_value_id
  end
  
  def down
    rename_column :fabric_options, :depends_on_option_value_id, :dependable_id
    rename_column :fabric_option_values, :depends_on_option_value_id, :dependable_id
  end
end
