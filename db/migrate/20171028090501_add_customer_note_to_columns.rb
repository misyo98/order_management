class AddCustomerNoteToColumns < ActiveRecord::Migration
  def up
    column_params = { name: 'customer_note', label: 'Customer Note(Woocommerce)', order: 73 }

    LineItemScope.find_each do |scope|
      scope.columns.create!(column_params)
    end
  end

  def down
    Column.where(columnable_type: 'LineItemScope', name: 'customer_note').delete_all
  end
end
