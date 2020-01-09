class CreateValidationParameters < ActiveRecord::Migration
  def change
    create_table :validation_parameters do |t|
      t.references :measurement_validation, index: true, foreign_key: true
      t.string :name
      t.text :original_expression
      t.text :calculation_expression

      t.timestamps null: false
    end
  end
end
