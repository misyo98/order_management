class ChangeColumnTypesInEstimatedCogs < ActiveRecord::Migration
  def change
    change_column :estimated_cogs, :cmt, :decimal, precision: 5, scale: 2
    change_column :estimated_cogs, :fabric_consumption, :decimal, precision: 5, scale: 2
    change_column :estimated_cogs, :estimated_inbound_shipping_costs, :decimal, precision: 5, scale: 2
    change_column :estimated_cogs, :estimated_duty, :decimal, precision: 5, scale: 2
  end
end
