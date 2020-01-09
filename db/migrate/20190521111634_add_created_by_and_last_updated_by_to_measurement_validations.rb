class AddCreatedByAndLastUpdatedByToMeasurementValidations < ActiveRecord::Migration
  def change
    add_column :measurement_validations, :last_updated_by_id, :integer, after: :execution_errors
    add_column :measurement_validations, :created_by_id, :integer, after: :execution_errors
  end
end
