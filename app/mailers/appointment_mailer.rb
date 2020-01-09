class AppointmentMailer < ActionMailer::Base
  def send_booking_reminder(receivers:, appointments:, url:)
    @receivers = receivers
    @appointments = appointments
    @url = url
    mail(to: nil, bcc: @receivers, subject: "Appointment list is not updated")
  end
end
