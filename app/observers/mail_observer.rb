class MailObserver
  def self.delivered_email(message)
    # for marking email in queue as sent, change this behaviour later if
    # new emails will be added somewhere
    email = EmailsQueue.by_customer_email(message.to[0]).not_sent.first
    email.mark_as_sent! if email
  end
end
