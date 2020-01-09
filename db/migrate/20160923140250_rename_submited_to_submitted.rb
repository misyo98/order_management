class RenameSubmitedToSubmitted < ActiveRecord::Migration
  def change
    rename_column :profiles, :submited, :submitted
  end
end
