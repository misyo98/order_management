class AddTagsColumnToLineItemScopes < ActiveRecord::Migration
  def up
    column_params = { name: 'tags_field', label: 'Tags', order: 116 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'tags_field').delete_all
  end
end
