module LineItems
  module UpdateState
    extend self

    def update_shipped_confirmed
      items = LineItem.shipped_confirmed_state
        .where(LineItemStateTransition.arel_table[:created_at].lteq(5.days.ago))
      items.map(&:completed!)
    end
  end
end
