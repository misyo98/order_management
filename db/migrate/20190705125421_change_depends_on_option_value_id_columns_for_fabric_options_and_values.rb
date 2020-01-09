class ChangeDependsOnOptionValueIdColumnsForFabricOptionsAndValues < ActiveRecord::Migration
  def up
    remove_reference :fabric_options, :depends_on_option_value
    remove_reference :fabric_option_values, :depends_on_option_value
    add_column :fabric_options, :depends_on_option_value_ids, :text
    add_column :fabric_option_values, :depends_on_option_value_ids, :text
  end

  def down
    remove_column :fabric_options, :depends_on_option_value_ids
    remove_column :fabric_option_values, :depends_on_option_value_ids
    add_reference :fabric_options, :depends_on_option_value, after: :fabric_tab_id, index: true
    add_reference :fabric_option_values, :depends_on_option_value, after: :fabric_option_id, index: true
  end
end
