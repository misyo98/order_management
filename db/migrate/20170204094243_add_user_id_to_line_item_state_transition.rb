class AddUserIdToLineItemStateTransition < ActiveRecord::Migration
  def change
    add_column :line_item_state_transitions, :user_id, :integer, after: :to
  end
end
