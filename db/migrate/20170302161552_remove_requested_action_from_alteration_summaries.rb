class RemoveRequestedActionFromAlterationSummaries < ActiveRecord::Migration
  def up
    remove_column :alteration_summaries, :requested_action
  end

  def down
    add_column :alteration_summaries, :requested_action, :integer, after: :non_altered_items
  end
end
