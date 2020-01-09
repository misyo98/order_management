class EventLinkDecorator < Draper::Decorator
  def default_link(item_ids)
    h.link_to(self.to_s.humanize, h.batch_trigger_state_line_items_path(event: self, ids: item_ids),
              remote: true, class: h.state_button_classes(event: self), method: :patch, data: { 'state-event': self })
  end

  def extra_link(item_ids)
    order = LineItem.find_by(id: item_ids.first).order

    h.link_to(self.to_s.humanize, h.edit_customer_profile_path(customer_id: order.customer_id, id: order.customer.profile_id, line_item_id: item_ids),
              remote: false, class: h.extra_button_classes(event: self))
  end
end
