class AddStateEnteredDateToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :state_entered_date, :datetime, after: :sent_to_alteration_date

    LineItem.reset_column_information
    LineItem.includes(:logged_events).find_each do |item|
      last_state_date = item.logged_events.last_entered_state(item.state)&.created_at
      item.update_column(:state_entered_date, last_state_date) if last_state_date
    end
  end

  def down
    remove_column :line_items, :state_entered_date
  end
end
