task check_for_not_sent_emails: :environment do
  not_sent_emails = EmailsQueue.where(EmailsQueue.arel_table[:created_at].gteq(DateTime.current - 25.hours)).not_sent

  if not_sent_emails.any?
    User::RECEIVE_NOT_SENT_EMAILS_WARNING.each do |recipient|
      EmailsQueuesMailer.not_sent_emails_warning_email(recipient, not_sent_emails).deliver
    end
  end
end
