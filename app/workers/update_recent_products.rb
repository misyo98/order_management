class UpdateRecentProducts
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Woocommerce::Hub.update_recent_products
  end
end