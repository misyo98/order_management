class AddOrderToCategoryParam < ActiveRecord::Migration
  def change
    add_column :category_params, :order, :integer, after: :param_id
  end
end
