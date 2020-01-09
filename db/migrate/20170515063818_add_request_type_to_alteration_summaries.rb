class AddRequestTypeToAlterationSummaries < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :request_type, :integer, after: :remaining_items
  end
end
