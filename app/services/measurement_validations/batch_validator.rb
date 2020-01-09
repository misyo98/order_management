module MeasurementValidations
  class BatchValidator
    BatchResult = Struct.new('BatchValidationResult', :errors)

    def self.validate(*attrs)
      new(*attrs).validate
    end

    def initialize(params:, category_params:, fit_params: {}, validator: nil, summary_id: nil)
      @params = params
      @category_params = category_params
      @fit_params = fit_params
      @validator = validator.presence || MeasurementValidations::Validator
      @summary_id = summary_id
      @result = BatchResult.new({})
    end

    def validate
      category_params.each do |category_param|
        validation_response = validator.validate(validator_params(category_param))
        result.errors[category_param.id] = validation_response.errors
      end

      result
    end

    private

    attr_reader :params, :category_params, :fit_params, :validator, :summary_id, :result

    def validator_params(category_param)
      {
        params: params,
        category_param: category_param,
        validations: category_param.measurement_validations,
        fit_params: fit_params
      }.tap { |params| params[:summary_id] = summary_id if summary_id.present? }
    end
  end
end
