# frozen_string_literal: true

class FabricTierCategoryDecorator < Draper::Decorator
  delegate_all

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

  def country_specific_category_price
    if h.current_user.gb_user?
      "#{price.dig('GBP')} GBP"
    else
      "#{price.dig('SGD')} SGD"
    end
  end
end
