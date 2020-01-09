module LineItems
  class TriggerState
    ALL_EVENTS = %i(chase_payment wait trigger_manufacturing hold measured saved_to_be_reviewed
                    saved_to_be_submitted reviewed_not_ok profile_submission
                    manufacturer_order_creation manufacturer_order_created fabric_ordered
                    fabric_received item_submitted oos_resolved got_out_of_stock inbounding at_office
                    inbound_number_added wait_fot_other_items wait_for_other_items_from_alteration
                    send_delivery_appt_email ship_items fit_confirmed_completed alteration_appointment_arranged
                    completed alteration_requested remake_requested delivery_arranged wait_for_other_items
                    sent_to_alterations_tailor back_from_alteration prepare_shipment remade refund cancel
                    delete_item back_to_delivery_email_sent shipped_fit_not_confirmed).freeze
    Response = Struct.new(:item, :items_for_mass_update)

    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(params)
      @item   = LineItem.unscoped.find(params[:id])
      @params = params
    end

    def call
      state_event = params[:state_event].to_sym
      if state_event.in? ALL_EVENTS
        item.public_send(state_event, user_id: params[:user_id])
      end
      result
    end

    private

    attr_reader :params, :item

    def result
      Response.new(item, items_for_mass_update)
    end

    def items_for_mass_update
      if item.completed? || item.shipped_confirmed?
        item.order.line_items
      else
        []
      end
    end
  end
end
