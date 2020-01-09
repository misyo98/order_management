class AddAlterationTailorIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :alteration_tailor_id, :integer
  end
end
