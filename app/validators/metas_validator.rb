class MetasValidator
  def initialize(params)
    @label = params[:label]
    @value = params[:value]
    @errors = []
  end

  def valid?
    validate_label
    validate_value
    error_messages.blank?
  end

  def error_messages
    errors
  end

  private

  attr_reader :label, :value
  attr_accessor :errors

  def validate_label
    errors << "Label can't be blank" if label.blank?
  end

  def validate_value
    errors << "Value can't be blank" if value.blank?
  end
end
