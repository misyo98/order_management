class CreateUserSalesLocations < ActiveRecord::Migration
  def change
    create_table :user_sales_locations do |t|
      t.references :user, index: true, foreign_key: true
      t.references :sales_location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
