class AddReminderEmailsToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'reminder_emails', label: 'Reminder Emails: ON/OFF', order: 74 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'reminder_emails').delete_all
  end
end
