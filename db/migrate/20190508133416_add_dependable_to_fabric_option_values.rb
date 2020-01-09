class AddDependableToFabricOptionValues < ActiveRecord::Migration
  def change
    add_reference :fabric_option_values, :dependable, after: :fabric_option_id, index: true
  end
end
