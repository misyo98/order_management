namespace :line_items do
  desc "Update line items with state shipped_confirmed to completed after 5 days"
  task undate_shipped_confirmed: :environment do
    LineItems::UpdateState.update_shipped_confirmed
  end
end
