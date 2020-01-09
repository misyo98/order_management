class AddOutfitterSelectionToFabricOptionValues < ActiveRecord::Migration
  def change
    add_column :fabric_option_values, :outfitter_selection, :integer, default: 0, after: :manufacturer
  end
end
