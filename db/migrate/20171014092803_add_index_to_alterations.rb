class AddIndexToAlterations < ActiveRecord::Migration
  def change
    add_index :alterations, :measurement_id
    add_index :alterations, :author_id
    add_index :alterations, :alteration_summary_id
    add_index :alterations, :category_param_value_id
  end
end
