namespace :alteration_summary do
  desc "Sends weekly alteration summary emails"
  task weekly: :environment do
    User.all.select(:email, :id).each do |user|
      SummaryMailer.weekly(receiver: user).deliver_now
    end
  end

  desc "Sends monthly alteration summary emails"
  task monthly: :environment do
    User.all.select(:email, :id).each do |user|
      SummaryMailer.monthly(receiver: user).deliver_now
    end
  end
end
