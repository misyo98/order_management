module MeasurementValidations
  class Preprocessor
    PATTERN_REGEX = /(\{\{.*?\}\})/ # returns {{}} with inside content
    BRACKETS_REGEX = /({{|}})/ # returns matching brackets {{ or }}

    attr_reader :errors

    def self.preprocess!(*attrs)
      new(*attrs).preprocess!
    end

    def initialize(measurement_validation)
      @measurement_validation = measurement_validation
      @validation_parameter_names = measurement_validation.validation_parameters.map(&:name)
      @result = Result.new
    end

    def preprocess!
      form_conditions

      result
    end

    private

    attr_reader :measurement_validation, :validation_parameter_names, :result

    def form_conditions
      measurement_validation.calculation_expression = replace_name_with_id(measurement_validation.original_expression)
      measurement_validation.and_condition = replace_name_with_id(measurement_validation.original_and_condition)

      measurement_validation.validation_parameters.each do |parameter|
        parameter.calculation_expression = replace_name_with_id(parameter.original_expression)
      end
    end

    def replace_name_with_id(expression)
      expression.gsub(PATTERN_REGEX) do |pattern|
        content = pattern.gsub(BRACKETS_REGEX, '')

        #return raw pattern if it's parameters pattern
        next pattern if validation_parameter_names.include?(content)

        category, param, value_key = content.split('.')

        category_param = CategoryParam.select(:id).by_category_and_param_aliases(
          category: category,
          param: param
        ).first

        next result.errors << "Invalid pattern: #{pattern}" unless category_param
        next result.errors << "Missing value key for: #{pattern}. Possible options: value, allowance, final_garment, body" unless value_key

        "{{#{category_param.id}->#{value_key}}}"
      end
    end
  end
end
