class CreateFittingGarmentMeasurements < ActiveRecord::Migration
  def change
    create_table :fitting_garment_measurements do |t|
      t.references :fitting_garment, index: true, foreign_key: { on_delete: :cascade }
      t.references :category_param, index: true, foreign_key: { on_delete: :cascade }
      t.decimal :value, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
