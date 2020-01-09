class AddFieldsToActiveAdminComment < ActiveRecord::Migration
  def change
    add_column :active_admin_comments, :category_id, :integer, after: :author_type
    add_column :active_admin_comments, :submission, :boolean, after: :category_id, default: 0
  end
end
