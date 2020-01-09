class AddParameterizedNameToValues < ActiveRecord::Migration
  def change
    add_column :values, :parameterized_name, :string

    Value.reset_column_information

    Value.find_each do |value|
      value.update_column(:parameterized_name, value.title.parameterize.underscore)
    end
  end
end
