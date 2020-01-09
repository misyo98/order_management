class AddRemakeToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :remake, :boolean, after: :complete, default: 0
  end
end
