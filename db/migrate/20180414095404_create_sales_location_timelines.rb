class CreateSalesLocationTimelines < ActiveRecord::Migration
  def change
    create_table :sales_location_timelines do |t|
      t.references :sales_location, index: true, foreign_key: true
      t.references :states_timeline, index: true, foreign_key: true
      t.integer :allowed_time
      t.integer :expected_delivery_time

      t.timestamps null: false
    end
  end
end
