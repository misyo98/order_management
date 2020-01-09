class AddOrderCommentFieldToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'order_comment_field', label: 'Order Comment', order: 63 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'order_comment_field').delete_all
  end
end
