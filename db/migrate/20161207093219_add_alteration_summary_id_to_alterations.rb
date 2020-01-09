class AddAlterationSummaryIdToAlterations < ActiveRecord::Migration
  def change
    add_column :alterations, :alteration_summary_id, :integer, after: :measurement_id
  end
end
