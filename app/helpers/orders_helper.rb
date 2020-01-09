# frozen_string_literal: true

module OrdersHelper
  ORDERS_TO_CREATE = 'orders_to_create'
  ORDERS_TO_REVIEW_AND_SUBMIT = 'orders_to_review_and_submit'
  SCOPES_WITH_COPY_BUTTON = [ORDERS_TO_CREATE, ORDERS_TO_REVIEW_AND_SUBMIT].freeze
  SCOPES_WITH_ALL_ORDERS = ['shipment_preparation', 'at_office_waiting', 'inbounding'].freeze

  def formatted_order_comments(measurement_comments, alteration_infos)
    measurement_comments = measurement_comments.to_a.map(&:body)
    alteration_comments = alteration_infos.to_a.map do |info|
      "Alteration #{alteration_infos.index(info) + 1}: #{info.comment}"
    end
    (measurement_comments + alteration_comments).join(' / ')
  end

  def copy_button_needed?(order, current_scope)
    order.customer.profile && current_scope.in?(SCOPES_WITH_COPY_BUTTON)
  end

  def pes_number_needed?(current_scope)
    current_scope == ORDERS_TO_REVIEW_AND_SUBMIT
  end

  def all_customer_orders_needed?(current_scope)
    current_scope.in?(SCOPES_WITH_ALL_ORDERS)
  end

  def resolve_items_collection(order, all_orders_needed)
    collection =
      if order.customer && all_orders_needed
        order.customer.line_items.triggered_into_production
      else
        order.line_items
      end
    collection.order(id: :desc)
  end
end
