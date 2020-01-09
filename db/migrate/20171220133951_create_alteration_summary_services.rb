class CreateAlterationSummaryServices < ActiveRecord::Migration
  def change
    create_table :alteration_summary_services do |t|
      t.references :alteration_summary
      t.references :alteration_service
      t.timestamps null: false
    end
  end
end
