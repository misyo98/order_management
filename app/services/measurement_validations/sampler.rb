module MeasurementValidations
  class Sampler
    def self.try_sample(*attrs)
      new(*attrs).try_sample
    end

    def initialize(validation_params, measurement_params, category_param, fit_params: {})
      @measurement_params = measurement_params
      @category_param = category_param
      @fit_params = fit_params
      @measurement_validation = MeasurementValidation.new(validation_params)
      @errors = { object: [], validation_result_errors: [] }
    end

    def try_sample
      if validate_object
        if preprocess_object
          run_validations
        end
      end

      flatenned_errors
    end

    private

    attr_reader :measurement_params, :category_param, :fit_params, :measurement_validation
    attr_accessor :errors

    def validate_object
      measurement_validation.valid?
      @errors[:object] = measurement_validation.errors.full_messages

      errors[:object].empty?
    end

    def preprocess_object
      preprocessor = Preprocessor.preprocess!(measurement_validation)
      @errors[:object] = preprocessor.errors

      preprocessor.success?
    end

    def run_validations
      validator = Validator.validate(
        params: measurement_params,
        category_param: category_param,
        validations: [measurement_validation],
        fit_params: fit_params,
        keep_log: true
      )

      @errors[:object] << measurement_validation.execution_errors
      @errors[:validation_result_errors] = validator.errors
      @errors[:log] = validator.data
    end

    def flatenned_errors
      {
        object: errors[:object].flatten,
        validation_result_errors: errors[:validation_result_errors].flatten,
        log: errors[:log]
      }
    end
  end
end
