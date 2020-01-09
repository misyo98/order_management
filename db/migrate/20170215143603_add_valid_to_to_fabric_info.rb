class AddValidToToFabricInfo < ActiveRecord::Migration
  def change
    add_column :fabric_infos, :valid_from, :date, after: :fabric_addition
  end
end
