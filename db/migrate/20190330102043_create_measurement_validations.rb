class CreateMeasurementValidations < ActiveRecord::Migration
  def change
    create_table :measurement_validations do |t|
      t.references :category_param, index: true, foreign_key: true
      t.string :left_operand
      t.string :comparison_operator
      t.text :original_expression
      t.text :calculation_expression
      t.text :and_condition
      t.text :original_and_condition
      t.text :error_message
      t.text :fits
      t.text :comment
      t.text :execution_errors

      t.timestamps null: false
    end
  end
end
