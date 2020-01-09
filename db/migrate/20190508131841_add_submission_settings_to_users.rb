class AddSubmissionSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_submit_measurements, :boolean
    add_column :users, :can_review_measurements, :boolean
  end
end
