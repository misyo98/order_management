class MeasurementsController < ApplicationController
  respond_to :html, :json, :js

  def new
    customers        = Customer.limit(10).select(:id, :first_name, :last_name, :email)
    @customers       = CustomerDecorator.decorate_collection(customers)
    @categories      = Category.all.order(:order)
    @outfitter       = current_user.decorate
    @customer        = Customer.find_by(id: params[:customer_id])&.decorate
    @review          = ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:review])
  end

  def checks
    @categories = Category.visible.order(:order)
    @checks = MeasurementCheck.for_checks_table
  end

  def validate
    category_param = CategoryParam.find(params[:category_param_id])
    validations = category_param.measurement_validations

    result = MeasurementValidations::Validator.validate(
      params: params[:form][:profile][:measurements_attributes],
      category_param: category_param,
      validations: validations,
      fit_params: params[:fits][:profile][:fits_attributes]
    )

    render json: { errors: result.errors }, status: :ok
  end

  def batch_validate
    category_params = CategoryParam.preload(measurement_validations: :validation_parameters).where(id: params[:category_param_ids])

    result = MeasurementValidations::BatchValidator.validate(
      params: params[:form][:profile][:measurements_attributes],
      category_params: category_params,
      fit_params: params[:fits][:profile][:fits_attributes],
      validator: params[:summary_id].presence && MeasurementValidations::AlterationValidator,
      summary_id: params[:summary_id]
    )

    render json: { errors: result.errors }, status: :ok
  end

  def validate_with_dependencies
    category_param = CategoryParam.find(params[:category_param_id])

    result = MeasurementValidations::BatchValidator.validate(
      params: params[:form][:profile][:measurements_attributes],
      category_params: [category_param, *category_param.dependable_category_params],
      fit_params: params[:fits][:profile][:fits_attributes]
    )

    render json: { errors: result.errors }, status: :ok
  end

  def validate_alteration
    category_param = CategoryParam.find(params[:category_param_id])
    validations = category_param.measurement_validations

    result = MeasurementValidations::AlterationValidator.validate(
      params: params[:form][:profile][:measurements_attributes],
      category_param: category_param,
      validations: validations,
      fit_params: params[:fits][:profile][:fits_attributes],
      summary_id: params[:to_be_validated_summary_id]
    )

    render json: { errors: result.errors }, status: :ok
  end
end
