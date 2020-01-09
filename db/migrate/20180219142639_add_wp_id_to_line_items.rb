class AddWpIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :wp_id, :integer

    add_index :line_items, [:order_id, :wp_id]
  end
end
