class AddFieldsToAlterationSummaries < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :urgent, :boolean, after: :profile_id
    add_column :alteration_summaries, :requested_completion, :date, after: :urgent
    add_column :alteration_summaries, :alteration_request_taken, :date, after: :requested_completion
    add_column :alteration_summaries, :delivery_method, :integer, after: :alteration_request_taken
    add_column :alteration_summaries, :non_altered_items, :integer, after: :delivery_method
    add_column :alteration_summaries, :requested_action, :integer, after: :non_altered_items
    add_column :alteration_summaries, :remaining_items, :integer, after: :requested_action
    add_column :alteration_summaries, :additional_instructions, :text, after: :remaining_items
  end
end
