ActiveAdmin.register MeasurementValidation do
  belongs_to :category_param

  config.filters = false
  actions :all, except: [:show]

  permit_params :id, :category_param_id, :left_operand, :comparison_operator,
    :original_expression, :original_and_condition, :error_message, :comment, fits: [],
    validation_parameters_attributes: %i(id measurement_validation_id name original_expression _destroy)

  member_action :copy_validation_dropdown, method: :get
  member_action :create_validation_copy, method: :post

  collection_action :test, method: :post

  form do |f|
    render(
      'admin/measurement_validations/form',
      measurement_validation: f.object,
      category_params: category_params,
      categories: categories,
      category_param: category_param,
      category_param_values: category_param_values,
      values: values
    )
  end

  index do
    id_column
    column(:left_operand)
    column(:comparison_operator)
    column('Expression', humanize_name: false) { |validation| validation.original_expression }
    column('AND Condition', humanize_name: false) { |validation| validation.original_and_condition }
    column(:error_message)
    column('Restricted for fits', humanize_name: false) do |validation|
      if validation.fits.empty?
        'All'
      else
        validation.fits.select(&:present?).map(&:humanize).join(', ')
      end
    end
    column(:comment)
    column(:execution_errors_count) { |validation| validation.execution_errors.count }
    column(:created_by)
    column(:last_updated_by)
    column(:created_at)
    column(:updated_at)
    actions do |validation|
      item 'Copy', copy_validation_dropdown_category_param_measurement_validation_path(category_param_id: validation.category_param.id, id: validation.id),
        class: 'copy-validation-button', remote: true
    end
  end

  controller do
    def new
      @category_params = CategoryParam.all
      @categories = Category.all
      @category_param_values = CategoryParamValue.all
      @values = Value.all

      super
    end

    def edit
      @category_params = CategoryParam.all
      @categories = Category.all
      @category_param_values = CategoryParamValue.all
      @values = Value.all

      super
    end

    def create
      @category_param = CategoryParam.find(params[:category_param_id])
      @measurement_validation = MeasurementValidations::Creator.create(permitted_params[:measurement_validation]
        .merge(created_by_id: current_user.id))

      if @measurement_validation.persisted?
        redirect_to category_param_measurement_validations_path(@category_param)
      else
        @category_params = CategoryParam.all
        @categories = Category.all
        @category_param_values = CategoryParamValue.all
        @values = Value.all

        render :new
      end
    end

    def update
      @category_param = CategoryParam.find(params[:category_param_id])
      @measurement_validation = MeasurementValidation.find(params[:id])
      MeasurementValidations::Updater.update(@measurement_validation, permitted_params[:measurement_validation]
        .merge(last_updated_by_id: current_user.id))

      if @measurement_validation.errors.empty?
        redirect_to category_param_measurement_validations_path(@category_param)
      else
        @category_params = CategoryParam.all
        @categories = Category.all
        @category_param_values = CategoryParamValue.all
        @values = Value.all

        render :edit
      end
    end

    def test
      category_param = CategoryParam.find(params[:category_param_id])

      @response = MeasurementValidations::Sampler.try_sample(
        permitted_params[:measurement_validation],
        params[:measurements],
        category_param,
        fit_params: params[:fits]
      )

      render 'admin/measurement_validations/test'
    end

    def copy_validation_dropdown
      @validation_id = params[:id]
      @category_param_id = params[:category_param_id]

      render 'admin/measurement_validations/copy_dropdown'
    end

    def create_validation_copy
      validation = MeasurementValidation.find(params[:id])

      validation.amoeba_dup.tap { |copy| copy.category_param_id = params[:measurement] }.save

      redirect_to category_param_measurement_validations_path(category_param_id: params[:measurement])
    end
  end
end
