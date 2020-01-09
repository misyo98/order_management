class AddRemakeCategoryToLineItems < ActiveRecord::Migration
  def up
    add_column :line_items, :remake_category, :text

    column_params = { name: 'remake_category_field', label: 'Remake Category', order: 81 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :remake_category

    Column.where(columnable_type: 'LineItemScope', name: 'remake_category_field').delete_all
  end
end
