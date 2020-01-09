class AddRiseDropdownOptionToProfiles < ActiveRecord::Migration
  def up
    Param.create(id: 78, title: 'Rise', alias: 'Rise Dropdown', input_type: :values)
    Value.create(id: 32, title: 'Low')
    CategoryParam.create(id: 102, category_id: 8, param: Param.find_by(alias: 'Rise Dropdown'), order: 102)
    CategoryParamValue.create(id: 50, category_param: CategoryParam.joins(:param, :category).find_by('params.title' => 'Rise', 'categories.name' => 'Body shape & postures'), value_id: Value.find_by(title: 'Low').id)
    CategoryParamValue.create(id: 51, category_param: CategoryParam.joins(:param, :category).find_by('params.title' => 'Rise', 'categories.name' => 'Body shape & postures'), value_id: Value.find_by(title: 'Regular').id)
    CategoryParamValue.create(id: 52, category_param: CategoryParam.joins(:param, :category).find_by('params.title' => 'Rise', 'categories.name' => 'Body shape & postures'), value_id: Value.find_by(title: 'High').id)

    category_param_id = CategoryParam.joins(:param, :category).find_by('params.title' => 'Rise', 'categories.name' => 'Body shape & postures').id
    category_param_value_id = CategoryParamValue.where(category_param_id: category_param_id).find_by_title('Regular').id

    Profile.find_each do |profile|
      profile.measurements.create(
        category_param_id: category_param_id,
        category_param_value_id: category_param_value_id
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
