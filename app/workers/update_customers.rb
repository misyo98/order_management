class UpdateCustomers
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Woocommerce::Hub.update_customers
  end
end