class AddTuxedoToFabricCategories < ActiveRecord::Migration
  def change
    add_column :fabric_categories, :tuxedo, :boolean, after: :updated_at
  end
end
