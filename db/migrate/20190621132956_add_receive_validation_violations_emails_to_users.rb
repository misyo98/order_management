class AddReceiveValidationViolationsEmailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_validation_violations_emails, :boolean
  end
end
