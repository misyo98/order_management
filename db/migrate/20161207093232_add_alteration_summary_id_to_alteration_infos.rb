class AddAlterationSummaryIdToAlterationInfos < ActiveRecord::Migration
  def change
    add_column :alteration_infos, :alteration_summary_id, :integer, after: :author_id
  end
end
