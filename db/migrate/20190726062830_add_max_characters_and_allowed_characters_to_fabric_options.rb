class AddMaxCharactersAndAllowedCharactersToFabricOptions < ActiveRecord::Migration
  def change
    add_column :fabric_options, :max_characters, :integer
    add_column :fabric_options, :allowed_characters, :text
  end
end
