class CreateSalesLocations < ActiveRecord::Migration
  def change
    create_table :sales_locations do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
