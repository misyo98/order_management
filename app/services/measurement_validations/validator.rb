# frozen_string_literal: true

module MeasurementValidations
  class Validator
    PATTERN_REGEX = /(\{\{.*?\}\})/ # returns {{}} with inside content
    BRACKETS_REGEX = /({{|}})/ # returns matching brackets {{ or }}
    EXPRESSION_SEPARATOR = '->'
    EXPRESSION_RESULT_PATTERN = '{{expression_result}}'

    def self.validate(*attrs)
      new(*attrs).validate
    end

    def initialize(params:, category_param:, validations:, fit_params: {}, keep_log: false)
      @params = params
      @category_param = category_param
      @validations = validations
      @keep_log = keep_log
      @selected_fit = resolve_fit(fit_params)
      @result = Result.new
    end

    def validate
      filtered_validations.each do |validation_rule|
        begin
          parameters = set_parameters(validation_rule.validation_parameters)
          expression = interpret_expression(validation_rule.calculation_expression, parameters)
          and_condition = maybe_and_condition(validation_rule)
          left_operand = interpret_left_operand(validation_rule.left_operand)

          string_expression = "#{left_operand} #{validation_rule.comparison_operator} (#{expression})"
          string_expression += " && #{and_condition}" if and_condition

          if eval(string_expression)
            result.errors << validation_rule.error_message.gsub(EXPRESSION_RESULT_PATTERN, eval(expression).to_s)
          end

          maybe_write_log(string_expression, parameters, and_condition)
        rescue StandardError, SyntaxError => error
          validation_rule.execution_errors << error.message
          validation_rule.save if validation_rule.persisted?
        end
      end

      result
    end

    private

    attr_reader :params, :category_param, :validations, :result, :selected_fit, :keep_log

    def resolve_fit(fit_params)
      category_fit_param = fit_params.find do |_, params|
        params['category_id'] == category_param.category_id.to_s
      end
      category_fit_param&.last&.dig('fit')
    end

    def filtered_validations
      return validations if selected_fit.nil?
      validations.select do |validation|
        validation.fits.select(&:present?).empty? || validation.fits.include?(selected_fit)
      end
    end

    def set_parameters(parameters)
      parameters.each_with_object({}) do |parameter, response|
        string_expression = interpret_expression(parameter.calculation_expression)
        response[parameter.name] = eval(string_expression).to_s
      end
    end

    def interpret_expression(expression, parameters = {})
      expression.gsub(PATTERN_REGEX) do |pattern|
        content = pattern.gsub(BRACKETS_REGEX, '')

        #return parameter value if it's parameters pattern
        next parameters[content] if parameters.keys.include?(content)

        category_param_id, key = content.split(EXPRESSION_SEPARATOR)

        if key == 'body'
          param_value = CategoryParamValue.find(
            params[category_param_id]['adjustment_value_id'] || params[category_param_id]['category_param_value_id']
          )

          "\'#{param_value.value.parameterized_name}\'"
        else
          params[category_param_id][key]
        end
      end
    end

    def interpret_left_operand(operand)
      operand.gsub(PATTERN_REGEX) do |pattern|
        key = pattern.gsub(BRACKETS_REGEX, '')

        params[category_param.id.to_s][key]
      end
    end

    def maybe_and_condition(rule)
      if rule.and_condition.present?
        interpret_expression(rule.and_condition)
      end
    end

    def maybe_write_log(string_expression, parameters, and_condition)
      if keep_log
        result.data[:expression] = string_expression
        result.data[:extra_params] = parameters
        result.data[:and_condition] = and_condition if and_condition
      end
    end
  end
end
