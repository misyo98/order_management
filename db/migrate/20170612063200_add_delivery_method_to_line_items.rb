class AddDeliveryMethodToLineItems < ActiveRecord::Migration
  def up
    column_params = { name: 'delivery_method_post_alteration', label: 'Delivery Method Post Alteration', order: 61 }

    add_column :line_items, :delivery_method, :string, after: :delivery_appointment_date

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    remove_column :line_items, :delivery_method

    Column.where(columnable_type: 'LineItemScope', name: 'delivery_method_post_alteration').delete_all
  end
end
