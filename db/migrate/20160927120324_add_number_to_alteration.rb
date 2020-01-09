class AddNumberToAlteration < ActiveRecord::Migration
  def change
    add_column :alterations, :number, :integer, after: :id
  end
end
