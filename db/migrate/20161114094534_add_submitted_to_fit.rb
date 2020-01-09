class AddSubmittedToFit < ActiveRecord::Migration
  def change
    add_column :fits, :submitted, :boolean, after: :checked, default: 0
  end
end
