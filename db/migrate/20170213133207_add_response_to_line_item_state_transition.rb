class AddResponseToLineItemStateTransition < ActiveRecord::Migration
  def change
    add_column :line_item_state_transitions, :response, :text, after: :comment_body
  end
end
