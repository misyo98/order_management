class Api::LineItemsController < Api::ApplicationController
  before_action :add_origin_header, only: [:index]
  before_action :authenticate

  respond_to :json

  def index
    @items = LineItem.includes(:order).where(order_id: params[:order_id]).without_deleted
    @timelines = StatesTimeline.select(:state, :expected_delivery_time_uk, :expected_delivery_time_sg)

    respond_with @items
  end
end
