class AddReceiveAllAlterationEmailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_all_alteration_emails, :boolean, default: false
  end
end
