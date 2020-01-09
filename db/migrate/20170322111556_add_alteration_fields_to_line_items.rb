class AddAlterationFieldsToLineItems < ActiveRecord::Migration
  URGENT_ATTRS = { name: 'urgent_field', label: 'Urgent', order: 56 }.freeze

  def up
    add_column :line_items, :urgent, :boolean, after: :real_duty

    LineItemScope.includes(:columns).all.each do |scope|
      scope.columns.create!(URGENT_ATTRS)
    end
  end

  def down
    remove_column :line_items, :urgent, :boolean

    LineItemScope.includes(:columns).all.each do |scope|
      scope.columns.find_by(name: 'urgent_field').delete
    end
  end
end
