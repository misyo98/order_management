class AddTailorIdToLineItemStateTransition < ActiveRecord::Migration
  def change
    add_column :line_item_state_transitions, :tailor_id, :integer, after: :user_id
  end
end
