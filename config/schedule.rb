# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
env :PATH, ENV['PATH']
set :output, { error: "log/cron_error_log.log", standard: "log/cron_log.log" }

# every 2.minutes do
#   rake "woocommerce_customers:check_for_new"
# end

every 6.hours do
  rake "woocommerce_orders:check_for_new"
end

every :day, at: '1:00pm' do
  rake "appointment:send_booking_emails['SG']"
end

every :day, at: '9:00pm' do
  rake "appointment:send_booking_emails['GB']"
end

every :day, at: '10:00pm' do
  rake "line_items:undate_shipped_confirmed"
end

every :day, at: '1:00pm' do
  rake 'fabric_unavailability_notification:daily'
end

every :day, at: '9:00am' do
  rake 'check_for_not_sent_emails'
end

every :day, at: '0:10am' do
  rake 'remind_to_get_measured'
end

# every :day, at: '10:20pm' do
#   rake "woocommerce_products:check_for_new"
# end

# every :day, at: '10:40pm' do
#   rake "woocommerce_products:update_recent"
# end

# every :day, at: '11:00pm' do
#   rake "woocommerce_customers:update_all"
# end

# Uncomment when will go live
# every 30.minutes do
#   rake "accounting:upload_csv"
# end

every 6.hours do
  rake "woocommerce_orders:update_statuses"
end

# every 6.hours do
#   rake "woocommerce_customers:update_recent"
# end

every :monday, at: '04:05am' do
  rake "alteration_summary:weekly"
end

every 5.days, at: '00:15am' do
  rake "checks:initialize_values"
end

every 1.month, at: 'start of the month at 2am' do
  rake "alteration_summary:monthly"
end

every 5.days, at: '8:30 am' do
  runner "SendDeliveryReminders.perform_async"
end

# Learn more: http://github.com/javan/whenever
