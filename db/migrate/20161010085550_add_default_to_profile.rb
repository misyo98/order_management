class AddDefaultToProfile < ActiveRecord::Migration
  def change
    change_column :profiles, :submitted, :boolean, default: 0
  end
end
