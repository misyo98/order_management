class RenameMeasurementProfileToMeasurement < ActiveRecord::Migration
  def change
    rename_table :measurement_profiles, :measurements
  end
end
