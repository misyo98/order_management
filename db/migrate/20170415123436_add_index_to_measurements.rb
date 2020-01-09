class AddIndexToMeasurements < ActiveRecord::Migration
  def change
    add_index :measurements, :category_param_id
    add_index :measurements, :category_param_value_id
    add_index :measurements, :adjustment_value_id
  end
end
