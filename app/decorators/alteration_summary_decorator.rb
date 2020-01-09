# frozen_string_literal: true

class AlterationSummaryDecorator < Draper::Decorator
  DATE_FORMAT = '%Y-%m-%d %I:%M%p'
  COMPLETION_DATE_FORMAT = '%B %d, %Y'
  SEND_TO_TAILOR_FORMAT = '%B %d, %Y'
  URGENT = 'URGENT'
  YES = 'YES'
  NO = 'No'
  JOIN_SYMBOL = ', '
  RED_CLASS = 'mark-red'
  NOT_INVOICED = 'Not invoiced'
  PAYMENT_REQUIRED = 'PAYMENT REQUIRED'

  delegate_all

  def customer_field
    h.link_to customer_name, h.customer_path(profile.customer)
  end

  def created_by
    "#{alteration_infos&.first&.author_first_name} #{alteration_infos&.first&.author_last_name}"
  end

  def sales_person
    alteration_summary_line_items.last&.line_item&.sales_person&.full_name
  end

  def formatted_created_at
    created_at.strftime(DATE_FORMAT)
  end

  def manufacturer_code
    alteration_infos&.first&.manufacturer_code
  end

  def maybe_urgent_label
    URGENT if urgent
  end

  def maybe_payment_required_label
    PAYMENT_REQUIRED if payment_required
  end

  def customer_name
    "#{profile.customer_first_name} #{profile.customer_last_name}"
  end

  def customer_first_name
    profile.customer_first_name
  end

  def customer_last_name
    profile.customer_last_name
  end

  def urgent_field
    h.content_tag(:span, urgent ? YES : NO, class: urgent ? 'label label-danger' : 'label label-success')
  end

  def payment_required_field
    h.content_tag(:span, payment_required ? YES : NO, class: payment_required ? 'label label-danger' : 'label label-success')
  end

  def maybe_urgent_text
    urgent ? YES : NO
  end

  def maybe_payment_required_text
    payment_required ? YES : NO
  end

  def request_type_field
    h.content_tag(:span, resolve_action_status[:name], class: resolve_action_status[:class])
  end

  def due_date
    requested_completion&.strftime('%B %d, %Y')
  end

  def due_date_cell
    h.content_tag(:span, due_date, class: due_date_class)
  end

  def altered_categories_field
    altered_categories.join(JOIN_SYMBOL)
  end

  def formatted_delivery_method
    AlterationSummary::DELIVERY_METHODS.key(delivery_method&.to_sym)
  end

  def formatted_completion_date
    requested_completion&.strftime(COMPLETION_DATE_FORMAT)
  end

  def formatted_remaining_items
    AlterationSummary::REMAINING_ITEMS.key(remaining_items&.to_sym)
  end

  def formatted_non_altered_items
    AlterationSummary::NON_ALTERED_ITEMS.key(non_altered_items&.to_sym)
  end

  def get_alteration_talors
    alteration_tailors.pluck(:name).uniq.join(JOIN_SYMBOL)
  end

  def alteration_send_date
    get_alteration_date(:sent_to_alteration_date)
  end

  def alteration_back_date
    get_alteration_date(:back_from_alteration_date)
  end

  def get_alteration_date(field)
    dates = alteration_summary_line_items.pluck(field).compact
    dates.map do |date|
      date.strftime(COMPLETION_DATE_FORMAT)
    end.uniq.join(JOIN_SYMBOL)
  end

  def locations_of_sales
    sales_location_ids = LineItem.where(id: line_item_ids).pluck(:sales_location_id)

    return String.new if sales_location_ids.blank?

    SalesLocation.where(id: sales_location_ids).pluck(:name).join(JOIN_SYMBOL)
  end

  def updated_by
    "#{updater_first_name} #{updater_last_name}"
  end

  def pdf_path
    h.alteration_summary_path(id: id, format: :pdf)
  end

  def amount_field
    "#{amount} #{alteration_tailors&.first&.decorate&.formatted_currency}" unless amount.zero? && service_updated_at.nil?
  end

  def resolve_action_status_name
    resolve_action_status[:name]
  end

  def invoice_number
    h.link_to current_invoice&.id, h.view_invoice_path(id: current_invoice.id, format: :pdf) if current_invoice
  end

  def invoice_status
    current_invoice&.status&.humanize || NOT_INVOICED
  end

  def alteration_service_names
    alteration_services.pluck(:name).join('; <br>')
  end

  def currency
    alteration_tailors&.first&.decorate&.formatted_currency
  end

  def maybe_amount_link
    if amount.zero? && alteration_services.empty?
      amount_field
    else
      h.link_to amount_field, h.service_list_alteration_summary_path(model), class: 'alteration-service-list', remote: true
    end
  end

  def add_service_link_title
    if to_be_updated? || to_be_altered?
      'Add services'
    elsif to_be_invoiced?
      'Edit services'
    end
  end

  private

  def resolve_action_status
    @status ||=
      case
      when alteration?
        { name: 'Alteration', class: 'label label-info' }
      when remake?
        { name: 'Remake', class: 'label label-warning' }
      else
        { name: '', class: '' }
      end
  end

  def due_date_class
    if requested_completion <= Date.today ||
      items.sent_to_tailor_week_ago_or_more.any?
      RED_CLASS
    end
  end
end
