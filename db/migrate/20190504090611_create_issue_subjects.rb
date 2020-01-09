class CreateIssueSubjects < ActiveRecord::Migration
  def change
    create_table :issue_subjects do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
