class AddAliasToParams < ActiveRecord::Migration
  def change
    add_column :params, :alias, :string, after: :input_type
  end
end
