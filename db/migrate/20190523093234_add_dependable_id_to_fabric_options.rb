class AddDependableIdToFabricOptions < ActiveRecord::Migration
  def change
    add_reference :fabric_options, :dependable, after: :fabric_tab_id, index: true
  end
end
