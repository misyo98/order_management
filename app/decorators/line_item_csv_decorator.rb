class LineItemCsvDecorator < LineItemDecorator
  delegate_all

  def status
    global_state
  end

  def order_number_field
    order_number
  end

  def comment
    comment_field
  end

  def order_comment_field
    order.comment
  end

  def customer
    order_customer_id
  end

  def requested_completion_date
    model.completion_date
  end

  def manufacturer
    LineItem::MANUFACTURERS[model.manufacturer.to_sym]
  end

  def fabric_tracking_number
    model.fabric_tracking_number
  end

  def comment_for_tailor
    model.comment_for_tailor
  end

  def required_action
    LineItemDecorator::REQUIRED_ACTIONS[state].try(:join, ' or ')
  end

  def sales_person_field
    sales_person&.full_name
  end

  def location_of_sale
    sales_location_name
  end

  def measurement_status
    return 'n/a' unless order&.customer&.profile
    categories = order.customer.profile.categories.select { |profile_category| profile_category.category_name.in? local_category }
    return 'n/a' if categories.empty?
    categories.map(&:status).join(', ')
  end

  def fabric_code
    fabric_code_value
  end

  def inbound_tracking_number
    tracking_number
  end

  def outbound_tracking_number
    self[:outbound_tracking_number]
  end

  def to_be_shipped_date
    h.l(to_be_shipped, format: :order_date) if to_be_shipped
  end

  def sent_to_alteration_date_field
    h.l(sent_to_alteration_date, format: :order_date) if sent_to_alteration_date
  end

  def fabric_status
    LineItem::FABRIC_STATUSES[fabric_state&.to_sym]
  end

  def manufacturer_order_status
    LineItem::RC_STATES[m_order_status&.to_sym]
  end

  def manufacturer_order_number
    m_order_number
  end

  def alteration_tailor
    tailor&.name
  end

  def courier_company
    courier&.name
  end

  def is_remake
    'REMAKE' if remake
  end

  def deduction_sales_amount
    deduction_sales
  end

  def deduction_sales_person_field
    deduction_sales_person&.full_name
  end

  def deduction_sales_comment_field
    deduction_sales_comment
  end

  def deduction_ops_amount
    deduction_ops
  end

  def deduction_ops_person_field
    deduction_ops_person&.full_name
  end

  def deduction_ops_comment_field
    deduction_ops_comment
  end

  def occasion_date_field
    occasion_date
  end

  def delivery_method_post_alteration
    LineItem::DELIVERY_METHODS[delivery_method]
  end

  def reminder_emails
    send_reminders
  end

  def tags_field
    tags.map(&:name).join(', ')
  end

  def vat_export_field
    yes_or_no(model.vat_export)
  end

  def ordered_fabric
    yes_or_no(model.ordered_fabric)
  end

  def yes_or_no(boolean)
    return 'Empty' if boolean.nil?

    boolean ? 'YES' : 'NO'
  end

  def special_customizations_field
    maybe_special_customizations.join(', ')
  end
end
