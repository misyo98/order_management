class ChangeMOrderNumberToString < ActiveRecord::Migration
  def change
    change_column :line_items, :m_order_number, :string
  end
end
