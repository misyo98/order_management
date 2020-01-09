class AddIndexToRealCogs < ActiveRecord::Migration
  def change
    add_index :real_cogs, :manufacturer_id
  end
end
