class AddAuthorToProfileCategories < ActiveRecord::Migration
  def change
    add_reference :profile_categories, :author, index: true
  end
end
