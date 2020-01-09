class AddCategoriesToProduct < ActiveRecord::Migration
  def change
    add_column :products, :category, :string, after: :total_sales
  end
end
