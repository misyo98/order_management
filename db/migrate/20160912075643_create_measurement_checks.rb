class CreateMeasurementChecks < ActiveRecord::Migration
  def change
    create_table :measurement_checks do |t|
      t.integer :category_param_id
      t.decimal :min, precision: 8, scale: 2, default: 0
      t.decimal :max, precision: 8, scale: 2, default: 0

      t.timestamps null: false
    end
  end
end
