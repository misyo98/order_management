class RenameMeasurementInMeasurement < ActiveRecord::Migration
  def change
    rename_column :measurements, :measurement, :value
  end
end
