class AddParameterizedNameToParams < ActiveRecord::Migration
  def change
    add_column :params, :parameterized_name, :string

    Param.reset_column_information

    Param.find_each do |param|
      param.update_column(:parameterized_name, param.title.parameterize.underscore)
    end
  end
end
