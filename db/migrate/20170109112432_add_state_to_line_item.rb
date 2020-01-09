class AddStateToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :state, :string, after: :order_id
  end
end
