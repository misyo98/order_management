class AddCopiedToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :copied, :boolean, default: false
  end
end
