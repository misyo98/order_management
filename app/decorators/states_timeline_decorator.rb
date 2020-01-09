class StatesTimelineDecorator < Draper::Decorator
  BR_JOIN = '<br>'.freeze

  delegate_all

  def formatted_sales_location_info_html
    sales_location_timelines.map do |sales_location_timeline|
      "<b>#{sales_location_timeline.sales_location.name}</b>:<br>
      - Allowed time: #{sales_location_timeline.allowed_time} <br>
      - Expected Delivery Time: #{sales_location_timeline.expected_delivery_time}"
    end.join(BR_JOIN).html_safe
  end
end
