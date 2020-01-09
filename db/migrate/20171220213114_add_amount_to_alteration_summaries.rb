class AddAmountToAlterationSummaries < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :amount, :integer, default: 0
  end
end
