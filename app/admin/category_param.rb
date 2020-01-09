ActiveAdmin.register CategoryParam do
  menu parent: 'Settings', if: -> { current_user.admin? }

  config.sort_order = 'category_id_asc'
  actions :all, except: [:destroy, :new]

  permit_params dependable_category_param_ids: []

  filter :category_id_eq, as: :select, collection: Category.visible.pluck(:name, :id), label: 'Category'

  index download_links: false do
    column('Category') { |category_param| category_param.category_name }
    column('Measurement') { |category_param| category_param.param_title }
    column('Validations Count') do |category_param|
      link_to category_param.measurement_validations.count, category_param_measurement_validations_path(category_param)
    end
    column('Execution Errors Count') do |category_param|
      category_param.measurement_validations.collect { |v| v.execution_errors.any? }.count { |bool| bool }
    end

    column('Triggers validations for:') do |category_param|
      category_param.dependable_category_params.map(&:to_s).join(', ')
    end

    actions defaults: false do |category_param|
      item 'Add Validation', new_category_param_measurement_validation_path(category_param), class: 'view_link member_link'
      item 'Add Validation Trigger', edit_category_param_path(category_param), class: 'view_link member_link'
    end
  end

  form do |f|
    inputs 'Select measurements that should be re-validated after changes applied to this one' do
      input(
        :dependable_category_param_ids,
        as: :select,
        collection: CategoryParam.order(category_id: :asc).where.not(id: f.object.id),
        input_html: {
          multiple: true,
          class: 'selectpicker',
          data: {
            'actions-box' => true,
            'selected-text-format' => "count > 3"
          }
        }
      )
    end
    actions
  end
end
