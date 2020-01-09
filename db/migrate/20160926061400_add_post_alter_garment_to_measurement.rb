class AddPostAlterGarmentToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :post_alter_garment, :decimal, precision: 8, scale: 2, default: 0, after: :final_garment
  end
end
