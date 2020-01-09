module EventValidator

  def validate_order_creation
    errors.add(:manufacturer_order_number, "can't be blank") unless m_order_number.present?
  end
  
  def validate_manufacturer_select
    errors.add(:manufacturer, "can't be blank") if blank_manufacturer?
  end

  def validate_location
    errors.add(:location_of_sale, "can't be blank") unless sales_location_id.present?
  end

  def validate_outfitter
    errors.add(:sales_person, "can't be blank") unless sales_person_id.present?
  end

  def validate_alteration_tailor
    errors.add(:alteration_tailor, "can't be blank") unless alteration_tailor_id.present?
  end

  def validate_courier_company
    errors.add(:courier_company, "can't be blank") unless courier_company_id.present?
  end

  def validate_vat_export
    errors.add(:vat_export, "can't be blank") if vat_export.nil?
  end

  def validate_outbound_number
    errors.add(:outbound_tracking_number, "can't be blank") unless outbound_tracking_number.present?
  end
end
