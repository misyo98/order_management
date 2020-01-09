class AddCustomScopeToLineItemScopes < ActiveRecord::Migration
  def change
    add_column :line_item_scopes, :custom_scope, :string
  end
end
