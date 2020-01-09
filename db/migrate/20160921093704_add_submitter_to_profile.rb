class AddSubmitterToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :submitter_id, :integer, after: :author_id
  end
end
