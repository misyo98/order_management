class AddIndexesToLineItemTransitions < ActiveRecord::Migration
  def change
    add_index :line_item_state_transitions, :event
    add_index :line_item_state_transitions, :to
    add_index :line_item_state_transitions, :from
    add_index :line_item_state_transitions, :user_id
    add_index :line_item_state_transitions, :tailor_id
    add_index :line_item_state_transitions, :courier_id
  end
end
