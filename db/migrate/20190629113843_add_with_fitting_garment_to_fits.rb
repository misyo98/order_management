class AddWithFittingGarmentToFits < ActiveRecord::Migration
  def change
    add_column :fits, :with_fitting_garment, :boolean, default: 0
  end
end
