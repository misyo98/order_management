task update_urgent_value: :environment do
  AlterationSummary.where(urgent: nil).each do |summary|
    summary.update_attribute(:urgent, false)
  end
end