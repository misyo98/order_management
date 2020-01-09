# frozen_string_literal: true

class FabricOptionValueDecorator < Draper::Decorator
  delegate_all

  def active_field
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-active") do
      h.best_in_place model, :active, as: :select, collection: { false => 'No', true => 'Yes' },
      url: h.fabric_option_value_path(id: id, bip_update: true), activator: "##{id}-active"
    end.html_safe
  end

  def price_field
    if price
      price.map do |key, value|
        next if value.blank?

        "#{key}: #{value}"
      end.compact&.join(', ')
    else
      'Empty'
    end
  end
end
