class SummaryMailer < ActionMailer::Base
  def weekly(receiver:)
    @receiver = receiver
    @start_date = Date.today.last_week
    @end_date = Date.today.last_week.end_of_week
    mail(to: receiver.email, subject: 'Your weekly alterations summary')
  end

  def monthly(receiver:)
    @receiver = receiver
    @start_date = Date.today.prev_month.beginning_of_month
    @end_date = Date.today.prev_month.end_of_month
    mail(to: receiver.email, subject: 'Your monthly alterations summary')
  end
end
