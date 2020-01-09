class AddTuxedoToFabricOptionValues < ActiveRecord::Migration
  def change
    add_column :fabric_option_values, :tuxedo, :integer, after: :price
  end
end
