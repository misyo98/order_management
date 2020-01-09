class CreateMeasurementProfiles < ActiveRecord::Migration
  def change
    create_table :measurement_profiles do |t|
      t.references :customer, index: true, foreign_key: true
      t.integer :param_id
      t.integer :param_value_id
      t.integer :measurement
      t.integer :allowance
      t.integer :adjustment
      t.integer :final_garment

      t.timestamps null: false
    end
  end
end
