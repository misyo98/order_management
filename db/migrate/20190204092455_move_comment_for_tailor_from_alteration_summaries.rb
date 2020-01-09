class MoveCommentForTailorFromAlterationSummaries < ActiveRecord::Migration
  def up
    remove_column :alteration_summaries, :comment_for_tailor

    add_column :line_items, :comment_for_tailor, :string

    column_params = { name: 'comment_for_tailor', label: 'Comment for tailor', order: 117 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    add_column :alteration_summaries, :comment_for_tailor, :string

    remove_column :line_items, :comment_for_tailor

    Column.where(columnable_type: 'LineItemScope', name: 'comment_for_tailor').delete_all
  end
end
