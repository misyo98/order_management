class AddAuthorIdToAlterationInfo < ActiveRecord::Migration
  def change
    add_column :alteration_infos, :author_id, :integer, after: :category_id
  end
end
