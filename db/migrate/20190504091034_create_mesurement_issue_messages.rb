class CreateMesurementIssueMessages < ActiveRecord::Migration
  def change
    create_table :mesurement_issue_messages do |t|
      t.references :measurement_issue, index: true, foreign_key: true
      t.references :author, index: true
      t.string :body

      t.timestamps null: false
    end
  end
end
