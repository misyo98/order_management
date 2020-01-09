class AddViolatesValidationToAlterationSummaries < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :violates_validation, :boolean
  end
end
