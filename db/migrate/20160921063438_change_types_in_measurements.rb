class ChangeTypesInMeasurements < ActiveRecord::Migration
  def change
    change_column :measurements, :measurement, :decimal, precision: 8, scale: 2, default: 0
    change_column :measurements, :allowance, :decimal, precision: 8, scale: 2, default: 0
    change_column :measurements, :adjustment, :decimal, precision: 8, scale: 2, default: 0
    change_column :measurements, :final_garment, :decimal, precision: 8, scale: 2, default: 0
  end
end
