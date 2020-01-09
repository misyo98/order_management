class AddCommentsToAlterationTailors < ActiveRecord::Migration
  def change
    add_column :alteration_summaries, :comment_for_tailor, :string
  end
end
