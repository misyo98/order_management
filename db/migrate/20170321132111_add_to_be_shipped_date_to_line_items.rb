class AddToBeShippedDateToLineItems < ActiveRecord::Migration
  SHIPPED_DATE_ATTRS = { name: 'to_be_shipped_date', label: 'To Be Shipped Date', order: 54 }.freeze

  def up
    add_column :line_items, :to_be_shipped, :date, after: :outbound_tracking_number

    LineItemScope.includes(:columns).all.each do |scope|
      scope.columns.create!(SHIPPED_DATE_ATTRS)
    end
  end

  def down
    remove_column :line_items, :to_be_shipped

    LineItemScope.includes(:columns).all.each do |scope|
      scope.columns.find_by(name: 'to_be_shipped_date').delete
    end
  end
end
