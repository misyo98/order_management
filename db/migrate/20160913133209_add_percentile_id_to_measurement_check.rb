class AddPercentileIdToMeasurementCheck < ActiveRecord::Migration
  def change
    add_column :measurement_checks, :percentile_id, :integer, after: :percentile_of
  end
end
