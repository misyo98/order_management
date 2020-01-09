class RemainingCogDecorator < Draper::Decorator
  delegate_all

  def matching_order_item
    line_item_id || 'NO MATCH'
  end

  def cost_bucket
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-cost-bucket") do
      h.best_in_place model, :cost_bucket_id, as: :select, collection: h.assigns['cost_buckets'], activator: "##{id}-cost-bucket"
    end.html_safe
  end
end
