class AddFieldsToMeasurementCheck < ActiveRecord::Migration
  def change
    add_column :measurement_checks, :percentile_of, :integer, after: :max, default: 0
    add_column :measurement_checks, :calculations_type, :integer, after: :percentile_of, default: 0
  end
end
