class AddFittingGarmentColumnsToMeasurements < ActiveRecord::Migration
  def change
    add_reference :measurements, :fitting_garment_measurement, index: true, foreign_key: true
    add_column :measurements, :fitting_garment_value, :decimal, precision: 6, scale: 2
    add_column :measurements, :fitting_garment_changes, :decimal, precision: 6, scale: 2
  end
end
