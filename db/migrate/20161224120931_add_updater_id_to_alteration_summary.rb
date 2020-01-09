class AddUpdaterIdToAlterationSummary < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :updater_id, :integer, after: :additional_instructions
  end
end
