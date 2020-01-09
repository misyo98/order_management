class CreateAlterationSummaries < ActiveRecord::Migration
  def change
    create_table :alteration_summaries do |t|
      t.integer :profile_id

      t.timestamps null: false
    end
  end
end
