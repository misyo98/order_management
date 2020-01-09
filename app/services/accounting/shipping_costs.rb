module Accounting
  class ShippingCosts
    def initialize(params)
      tracking_number = params.fetch(:tracking_number)
      @shipping_costs = params.fetch(:shipping_costs).to_f
      @duty = params.fetch(:duty).to_f
      @items = LineItem.joins(:real_cog).select(:id, 'real_cogs.cogs_rc_usd').where(tracking_number: tracking_number)
    end

    def create
      perform
    end

    private

    attr_reader   :shipping_costs, :duty
    attr_accessor :items

    def perform
      items.each do |item|
        item.update_column(:real_inbound_ship_cost, calculate_cost(item.cogs_rc_usd))
        item.update_column(:real_duty, calculate_duty(item.cogs_rc_usd))
      end
    end

    def cog_rc_sum
      items.map(&:cogs_rc_usd).inject(&:+)
    end

    def calculate_cost(cog_rc = 0)
      (shipping_costs / cog_rc_sum * cog_rc).round(2)
    end

    def calculate_duty(cog_rc = 0)
      (duty / cog_rc_sum * cog_rc).round(2)
    end
  end
end