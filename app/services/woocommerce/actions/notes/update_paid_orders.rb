module Woocommerce
  module Actions
    module Notes
      class UpdatePaidOrders
        include Woocommerce::Helpers

        PAID_PATTERN = 'to Processing'.freeze

        def initialize
          @woocommerce = Woocommerce::NoteApi.new()
        end

        def call(order_ids:)
          orders = Order.where(id: order_ids)
          orders.each do |order|
            notes = woocommerce.order_notes(order_id: order.id)
            next if notes.blank?
            paid_date = scrape_paid_date(notes: notes)
            order.update_attribute(:paid_date, paid_date) if paid_date
          end

        rescue JSON::ParserError
        end

        private

        attr_reader :woocommerce

        def scrape_paid_date(notes:)
          notes.each do |note|
            return note['created_at'].to_date if note['note'].scan(PAID_PATTERN).any?
          end
          nil
        end
      end
    end
  end
end
