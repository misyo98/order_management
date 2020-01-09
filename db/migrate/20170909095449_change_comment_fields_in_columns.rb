class ChangeCommentFieldsInColumns < ActiveRecord::Migration
  def up
    Column.where(columnable_type: 'LineItemScope', name: 'comment').update_all(label: 'Item Comment')
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'comment').update_all(label: 'Comment')
  end
end
