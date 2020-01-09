class AlterationDecorator < Draper::Decorator
  NOT_FOR_DISPLAY_PARAMETERS = ['Waist (Button Position)', 'Waistcoat 1st Button Position', 'Calf'].freeze

  delegate_all

  def value_field
    category_param_value_id? ? category_param_value.value_title : alter_value
  end

  def not_for_display?
    measurement.param_title.in?(NOT_FOR_DISPLAY_PARAMETERS)
  end

  private

  def alter_value
    value == 0 ? nil : value
  end
end
