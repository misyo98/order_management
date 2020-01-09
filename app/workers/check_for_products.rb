class CheckForProducts
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Woocommerce::Hub.create_products
  end
end