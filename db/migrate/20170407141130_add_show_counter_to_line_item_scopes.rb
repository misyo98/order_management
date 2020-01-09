class AddShowCounterToLineItemScopes < ActiveRecord::Migration
  def change
    add_column :line_item_scopes, :show_counter, :boolean, default: false
    add_index :line_item_scopes, :show_counter
  end
end
