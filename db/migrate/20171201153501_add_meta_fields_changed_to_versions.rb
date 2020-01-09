class AddMetaFieldsChangedToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :meta_fields_changed, :boolean, default: false
  end
end
