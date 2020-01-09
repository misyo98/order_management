class AddUpdaterToActiveAdminComments < ActiveRecord::Migration
  def change
    add_column :active_admin_comments, :updater_id, :integer, after: :resource_type
  end
end
