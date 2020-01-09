class AddPriceToFabricOptions < ActiveRecord::Migration
  def change
    add_column :fabric_options, :price, :decimal, precision: 6, scale: 2, after: :allowed_characters
  end
end
