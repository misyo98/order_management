class CreateLineItemScopeSalesLocations < ActiveRecord::Migration
  def change
    create_table :line_item_scope_sales_locations do |t|
      t.references :line_item_scope, index: true, foreign_key: true
      t.references :sales_location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
