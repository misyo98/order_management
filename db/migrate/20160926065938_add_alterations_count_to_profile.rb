class AddAlterationsCountToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :alterations_count, :integer, after: :submitter_id, default: 0
  end
end
