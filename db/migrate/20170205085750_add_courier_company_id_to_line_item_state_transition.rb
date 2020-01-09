class AddCourierCompanyIdToLineItemStateTransition < ActiveRecord::Migration
  def change
    add_column :line_item_state_transitions, :courier_id, :integer, after: :tailor_id
  end
end
