class AddVisibleToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :visible, :boolean, default: true, after: :name
  end
end
