class AddLineItemIdsToAlterationSummaries < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :line_item_ids, :string, after: :profile_id
  end
end
