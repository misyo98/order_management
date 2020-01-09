# frozen_string_literal: true

module BookingTool
  class AppointmentCsvDecorator < AppointmentDecorator
    COMMA = ', '

    def maybe_customer_id
      customer.id if customer
    end

    def previous_order_numbers
      if previous_orders
        order_ids = previous_orders.pluck(:number).last(5).join(COMMA)
      end
    end

    def allocated_outfitter
      context[:sales_people].find { |id, name| id == allocated_outfitter_id }&.last
    end

    def existing_customer_with_several_orders
      to_yes_or_no(customer.present? && !customer.orders.last&.first_order?)
    end

    def formatted_cancelled
      to_yes_or_no(cancelled)
    end

    def formatted_purchased
      to_yes_or_no(purchased)
    end

    def formatted_active_booking
      to_yes_or_no(active_booking)
    end

    def no_purchase_reason_field
      AppointmentDecorator::REASONS[no_purchase_reason]
    end

    def comment
      follow_up_status
    end

    def formatted_call_count
      "Count: #{call_count}, Last time called: #{formatted_last_called_date}"
    end
  end
end
