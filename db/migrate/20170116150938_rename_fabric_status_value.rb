class RenameFabricStatusValue < ActiveRecord::Migration
  def change
    rename_column :line_items, :fabric_status_value, :fabric_state
  end
end
