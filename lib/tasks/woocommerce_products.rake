namespace :woocommerce_products do
  task check_for_new: :environment do
    CheckForProducts.perform_async
  end 
  task update_recent: :environment do
    UpdateRecentProducts.perform_async
  end

  task create: :environment do
    Woocommerce::Hub.create_products
  end

  task update: :environment do
    Woocommerce::Hub.update_recent_products
  end
end
