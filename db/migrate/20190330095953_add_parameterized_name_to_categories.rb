class AddParameterizedNameToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :parameterized_name, :string

    Category.reset_column_information

    Category.find_each do |category|
      category.update_column(:parameterized_name, category.name.parameterize.underscore)
    end
  end
end
