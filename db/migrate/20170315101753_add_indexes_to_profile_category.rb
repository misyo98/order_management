class AddIndexesToProfileCategory < ActiveRecord::Migration
  def change
    add_index :profile_categories, :category_id
    add_index :profile_categories, :profile_id
  end
end
