class RenameMeasurementInAlterations < ActiveRecord::Migration
  def change
    rename_column :alterations, :measurement, :value
  end
end
