class CheckForCustomers
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Woocommerce::Hub.create_customers
  end
end