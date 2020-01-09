class UpdateOrdersStatuses
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Woocommerce::Hub.update_orders_statuses
  end
end