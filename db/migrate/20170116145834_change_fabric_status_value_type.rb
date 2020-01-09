class ChangeFabricStatusValueType < ActiveRecord::Migration
  def change
    change_column :line_items, :fabric_status_value, :string
  end
end
