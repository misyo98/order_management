class AddMinAndMaxPercentilesToMeasurementChecks < ActiveRecord::Migration
  def change
    add_column :measurement_checks, :min_percentile, :integer, default: 5
    add_column :measurement_checks, :max_percentile, :integer, default: 95
  end
end
