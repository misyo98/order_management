class CheckForOrders
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Woocommerce::Hub.create_orders
  end
end