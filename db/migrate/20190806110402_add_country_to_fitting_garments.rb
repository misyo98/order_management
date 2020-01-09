class AddCountryToFittingGarments < ActiveRecord::Migration
  def change
    add_column :fitting_garments, :country, :string
  end
end
