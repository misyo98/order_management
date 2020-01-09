class AddTuxedoPriceToFabricCategories < ActiveRecord::Migration
  def change
    add_column :fabric_categories, :tuxedo_price, :json
  end
end
