class AddColumnsToAllowances < ActiveRecord::Migration
  def change
    add_column :allowances, :self_slim, :decimal, precision: 8, scale: 2, default: 0, after: :classic
    add_column :allowances, :self_regular, :decimal, precision: 8, scale: 2, default: 0, after: :self_slim
  end
end
