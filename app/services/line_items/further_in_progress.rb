module LineItems
  module FurtherInProgress
    extend self

    def call(item_ids, order_ids)
      Order.where(id: order_ids).joins(:line_items).where.not(LineItem.arel_table[:id].in(ids))
        .where(LineItem.arel_table[:state].in(LineItem::NOT_PROGRESS_STATES)).pluck('line_items.id')
    end
  end
end
