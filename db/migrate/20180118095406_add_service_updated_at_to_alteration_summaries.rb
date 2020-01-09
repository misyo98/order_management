class AddServiceUpdatedAtToAlterationSummaries < ActiveRecord::Migration
  def up
    add_column :alteration_summaries, :service_updated_at, :datetime

    AlterationSummary.reset_column_information
    AlterationSummary.where.not(amount: 0).each do |summary|
      summary.update_attribute(:service_updated_at, summary.updated_at)
    end
  end

  def down
    remove_column :alteration_summaries, :service_updated_at
  end
end
