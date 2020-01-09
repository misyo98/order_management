module LineItems
  module AvailableStates
    EXTRA_EVENTS = { alteration_requested: :open_alteration_form }

    extend self

    def find_similar_states(items:, user:)
      @user = user

      form_events(events: items.map(&:state_events), items: items)
    end

    private

    attr_reader :user

    def form_events(events:, items:)
      raw_events = events.flatten.uniq.select do |event|
                     events.all? { |array| array.include?(event) }
                   end

      { default: filter_unallowed(raw_events, items), extra: find_extra(raw_events, items) }
    end

    def filter_unallowed(raw_events, items)
      if items.map(&:gift_category?).uniq.exclude?(false)
        events = raw_events.dup
        events.delete_if { |event| !event.to_s.in?(LineItemDecorator::GIFT_STATE_EVENT_BUTTONS.values.flatten.uniq) }
      else
        events = raw_events.dup
        events.delete_if { |event| !event.to_s.in?(LineItemDecorator::STATE_EVENT_BUTTONS.values.flatten.uniq) }
        events.push(:hold) if items.map(&:new?).uniq.exclude?(false) && (user.admin? || user.ops?)
        events.push(:measured) if items.map(&:new_to_be_measured?).uniq.exclude?(false) && (user.admin? || user.ops?)
        events
      end
    end

    def find_extra(raw_events, items)
      return [] unless items_all_the_same?(items)

      events = raw_events.dup
      events.delete_if { |event| EXTRA_EVENTS.keys.exclude?(event) }
      events.map { |event| EXTRA_EVENTS[event] }
    end

    def items_all_the_same?(items)
      first_item = items.first
      items.all? { |item| item.order_id == first_item.order_id && item.product_category == first_item.product_category }
    end
  end
end
