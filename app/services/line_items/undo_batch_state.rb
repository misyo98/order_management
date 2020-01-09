module LineItems
  class UndoBatchState
    Response = Struct.new(:message, :items)

    def initialize(params)
      @ids   = params.fetch(:ids, [])
      @items = LineItem.includes(:logged_events).where(id: ids)
    end

    def call
      perform
      response
    end

    private

    attr_accessor :items
    attr_reader   :ids

    def response
      Response.new('All items were successfully reverted', items)
    end

    def perform
      items.each do |item|
        pervious_state = item.logged_events.last.from
        item.update_attribute(:state, pervious_state)
      end
    end
  end
end
