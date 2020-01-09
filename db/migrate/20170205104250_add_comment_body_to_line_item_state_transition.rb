class AddCommentBodyToLineItemStateTransition < ActiveRecord::Migration
  def change
    add_column :line_item_state_transitions, :comment_body, :text, after: :to
  end
end
