class AddCheckedToFit < ActiveRecord::Migration
  def change
    add_column :fits, :checked, :boolean, after: :fit, default: 0
  end
end
