class AddSubmittedToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :submitted, :boolean, default: 0, after: :post_alter_garment
  end
end
