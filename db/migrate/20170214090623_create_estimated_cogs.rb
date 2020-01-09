class CreateEstimatedCogs < ActiveRecord::Migration
  def change
    create_table :estimated_cogs do |t|
      t.string :country
      t.string :category
      t.string :canvas
      t.integer :cmt
      t.integer :fabric_consumption
      t.integer :estimated_inbound_shipping_costs
      t.integer :estimated_duty

      t.timestamps null: false
    end
  end
end
