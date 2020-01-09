class AddIndexToLineItems < ActiveRecord::Migration
  def change
    add_index :line_items, :state
  end
end
