class AddVisibleForToLineItemScopes < ActiveRecord::Migration
  def change
    add_column :line_item_scopes, :visible_for, :string, after: :states, default: User.roles.map(&:first)
  end
end
