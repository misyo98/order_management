# frozen_string_literal: true

class FabricManagerDecorator < Draper::Decorator
  delegate_all

  def status_field
    h.content_tag(:span, class: 'far fa-edit', 'aria-hidden': true, id: "#{id}-status") do
      h.best_in_place model, :status, as: :select, collection: FabricManager::STATUSES, activator: "##{id}-status",
        class: 'fabric-manager-status'
    end.html_safe
  end

  def estimated_restock_date_field
    h.content_tag(:span, class: ['far fa-edit', 'estimated-restock-date', discontinued? && 'hidden'], 'aria-hidden': true, id: "#{id}-estimated-restock-date") do
      h.best_in_place model, :estimated_restock_date, as: :date, activator: "##{id}-estimated-restock-date", class: 'bip-estimated-restock-date',
      place_holder: 'Unknown'
    end.html_safe
  end
end
