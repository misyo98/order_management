class CreateMeasurementValidationDependencies < ActiveRecord::Migration
  def change
    create_table :measurement_validation_dependencies do |t|
      t.references :depends_on, index: true
      t.references :dependant, index: true

      t.timestamps null: false
    end
  end
end
