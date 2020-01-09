# frozen_string_literal: true

class FabricTierDecorator < Draper::Decorator
  delegate_all

  def prices_field
    if fabric_tier_categories.any?
      fabric_tier_categories.map do |tier_category|
        fabric_category_label(tier_category) + tier_category.decorate.price_field
      end.join(', ').html_safe
    else
      'Empty'
    end
  end

  def fabric_category_label(tier_category)
    h.content_tag(:h4, h.content_tag(:span, tier_category.fabric_category.title, class: 'label label-success'))
  end
end
