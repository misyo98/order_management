# frozen_string_literal: true

class AlterationServiceDecorator < Draper::Decorator
  delegate_all
  
  def formatted_name
    if deleted_at?
      "(DELETED SERVICE) - #{name}"
    else
      name
    end
  end
  
  def formatted_price_field(tailor)
    "#{alteration_service_tailors.with_deleted.find_by(alteration_tailor_id: tailor&.id)&.price} #{tailor.formatted_currency}"
  end
end
