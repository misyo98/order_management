class AddOrderToLineItemScope < ActiveRecord::Migration
  def change
    add_column :line_item_scopes, :order, :integer, after: :states, default: 1
  end
end
