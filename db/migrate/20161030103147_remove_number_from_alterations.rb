class RemoveNumberFromAlterations < ActiveRecord::Migration
  def change
    remove_column :alterations, :number
  end
end
