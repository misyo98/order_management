class CreateMeasurementIssues < ActiveRecord::Migration
  def change
    create_table :measurement_issues do |t|
      t.references :issueable, index: true, polymorphic: true
      t.references :issue_subject, index: true, foreign_key: true
      t.boolean :fixed

      t.timestamps null: false
    end
  end
end
