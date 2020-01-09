class RenameCommentInLineItem < ActiveRecord::Migration
  def change
    rename_column :line_items, :comment, :comment_field
  end
end
