class AddCustomMeasuredToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :custom_measured, :boolean, default: false, after: :submitter_id
  end
end
