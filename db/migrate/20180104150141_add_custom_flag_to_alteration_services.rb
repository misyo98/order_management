class AddCustomFlagToAlterationServices < ActiveRecord::Migration
  def change
    add_column :alteration_services, :custom, :boolean, default: false
  end
end
