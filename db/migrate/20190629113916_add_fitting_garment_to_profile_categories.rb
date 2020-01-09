class AddFittingGarmentToProfileCategories < ActiveRecord::Migration
  def change
    add_reference :profile_categories, :fitting_garment, index: true, foreign_key: true
  end
end
