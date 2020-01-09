class AddSendRemindersToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :send_reminders, :boolean, default: true
  end
end
