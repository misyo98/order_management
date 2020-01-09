module LineItems
  class CRUD
    attr_accessor :response, :errors

    def initialize(params: {})
      @item     = LineItem.find_by(id: params.fetch(:id, 0))
      @params   = params
      @response = nil
      @errors   = []
    end

    def trigger_fabric_state
      fabric_state_event = (params[:line_item][:fabric_state] + '_fabric').to_sym
      if fabric_state_event.in? LineItem::FABRIC_EVENTS
        item.public_send(fabric_state_event, user_id: params[:user_id])
      end
    end

    def update_state
      previous_state = item.state
      item.update_attribute(:state, params[:line_item][:state])
      log_manual_state_change(previous_state: previous_state)
    end

    def update_shipments
      items = LineItem.where(tracking_number: params[:code])
      items.each { |item| update_shipment(item: item) }
      { item_count: items.count }
    end

    def create_remake
      if item.remake_category.any?
        item.trigger_manufacturing(user_id: params[:user_id])
        response = { remade_item: item, new_item: item }
      else
        ActiveRecord::Base.transaction do
          begin
            perform_remake
          rescue StateMachines::InvalidTransition => error
            errors << error
            raise ActiveRecord::Rollback
          end
        end
      end
    end

    def set_alteration_fields(attrs)
      item.update(attrs)
    end

    def update_refund
      refund = item.refunds.build(amount: params[:refund][:amount],
                                  reason: params[:refund][:reason],
                                  comment: params[:refund][:comment])
      if item.valid?
        item.update(amount_refunded: (item.amount_refunded + refund.amount))
        item.refund if item.amount_refunded == (item.total.to_f / 100)
      end
      item
    end

    def batch_update
      items = LineItem.where(id: params[:ids])

      items.each do |item|
        item.assign_attributes(item_attributes)

        item.save(validate: false)
      end
    end

    private

    attr_accessor :item
    attr_reader   :params

    def update_shipment(item:)
      item.update_attribute(:shipment_received_date, Date.today) if item.inbounding(user_id: params[:user_id])
    end

    def perform_remake
      duplicate = item.dup
      nullify_revenue(item: duplicate)
      remake_item(item: duplicate)
      item.remade(user_id: params[:user_id])

      response = { remade_item: item, new_item: duplicate }
    end

    def nullify_revenue(item:)
      item.subtotal         = 0
      item.total            = 0
      item.price            = 0
      item.amount_refunded  = 0
    end

    def remake_item(item:)
      item.remake = true
      item.m_order_number = nil
      item.m_order_status = nil
      item.tracking_number = nil
      item.shipped_date = nil
      item.shipment_received_date = nil
      item.outbound_tracking_number = nil
      item.alteration_tailor_id = nil
      item.courier_company_id = nil
      item.ordered_fabric = nil if item.ordered_fabric?
      item.fabric_tracking_number = nil
      item.fabric_ordered_date = nil

      item.save
      item.trigger_manufacturing!(user_id: params[:user_id])
    end

    def log_manual_state_change(previous_state:)
      new_state = item.state

      if new_state != previous_state
        item.logged_events.create(event: 'manual_state_change',
                                  from: previous_state,
                                  to: new_state,
                                  user_id: params[:user_id])
      end
    end

    def item_attributes
      params.require(:attributes).permit(LineItem.attribute_names)
    end
  end
end
