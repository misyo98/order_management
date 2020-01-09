class AddIncludeUnassignedItemsToLineItemScopes < ActiveRecord::Migration
  def change
    add_column :line_item_scopes, :include_unassigned_items, :boolean
  end
end
