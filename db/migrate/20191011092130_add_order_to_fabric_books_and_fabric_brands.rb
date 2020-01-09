class AddOrderToFabricBooksAndFabricBrands < ActiveRecord::Migration
  def change
    add_column :fabric_books, :order, :integer, after: :title
    add_column :fabric_brands, :order, :integer, after: :title
  end
end
