class AddReferenceToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :reference, :string
  end
end
