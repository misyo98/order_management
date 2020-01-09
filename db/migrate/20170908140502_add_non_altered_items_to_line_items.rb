class AddNonAlteredItemsToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :non_altered_items, :integer
  end
end
