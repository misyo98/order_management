class AddOrderToIssueSubjects < ActiveRecord::Migration
  def change
    add_column :issue_subjects, :order, :integer
  end
end
