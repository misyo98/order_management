class AddStateToAlterationSummary < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :state, :string
  end
end
