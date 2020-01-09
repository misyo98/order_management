class AddIndexesToProfile < ActiveRecord::Migration
  def change
    add_index :profiles, :customer_id
  end
end
