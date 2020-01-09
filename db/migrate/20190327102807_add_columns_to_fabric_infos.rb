class AddColumnsToFabricInfos < ActiveRecord::Migration
  def change
    add_reference :fabric_infos, :fabric_brand, index: true, before: :created_at
    add_reference :fabric_infos, :fabric_book, index: true, before: :created_at
    add_reference :fabric_infos, :fabric_tier, index: true, before: :created_at
    add_column :fabric_infos, :order, :integer, before: :created_at
    add_column :fabric_infos, :manufacturer, :integer, before: :created_at
    add_column :fabric_infos, :fusible, :boolean, before: :created_at
    add_column :fabric_infos, :premium, :boolean, before: :created_at
    add_column :fabric_infos, :season, :string, before: :created_at
    add_column :fabric_infos, :active, :boolean, before: :created_at
  end
end
