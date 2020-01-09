class EmailsQueueDecorator < Draper::Decorator
  delegate_all

  def sent_field
    h.content_tag(:span, sent? ? 'YES' : 'NO', class: sent? ? 'label label-success' : 'label label-danger')
  end

  def sent_date
    I18n.l(sent_at, format: :order_date) if sent_at
  end

  def customer_name
    h.link_to recipient.full_name, h.customer_path(recipient_id)
  end

  def customer_email
    recipient.email
  end

  def link
    options[:link]
  end

  def from
    options[:from]
  end

  def failed_to_be_sent?
    ((DateTime.now.to_i - created_at.to_i) / 1.minute) > 10 && not_sent?
  end

  def delivery_email_layout_field
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-delivery-email-layout") do
      h.best_in_place model, :delivery_email_layout, as: :select, collection: EmailsQueue::DELIVERY_EMAILS_LAYOUTS, activator: "##{id}-delivery-email-layout"
    end.html_safe
  end
end
