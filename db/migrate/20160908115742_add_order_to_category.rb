class AddOrderToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :order, :integer, after: :visible
  end
end
