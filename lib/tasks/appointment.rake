namespace :appointment do
  desc 'Send emails with appointments for country (GB or SG)'
  task :send_booking_emails, [:country] => :environment do |task, args|
    Appointment::SendReminder.call(country: args[:country])
  end
end
