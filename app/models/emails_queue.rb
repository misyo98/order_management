require 'sidekiq/api'
class EmailsQueue < ActiveRecord::Base
  DELIVERY_MAIL = :delivery_email
  DELIVERY_EMAILS_LAYOUTS = {
    regular: 'Regular',
    with_courier_button: 'With courier button'
  }.freeze

  acts_as_paranoid

  enum status: %i(not_sent sent)
  enum letter_type: %i(delivery_email shipping_email)
  enum delivery_email_layout: %i(regular with_courier_button)

  belongs_to :recipient, polymorphic: true
  belongs_to :subject, polymorphic: true
  belongs_to :customer, -> { where(emails_queues: { recipient_type: 'Customer' } ).includes(:emails_queues) }, foreign_key: 'recipient_id'

  serialize :options, Hash
  serialize :delivering_errors, Array

  delegate :id, to: :recipient, prefix: true

  validates :tracking_number, uniqueness: true, allow_blank: true, on: :create
  validates :recipient, presence: true, on: :create
  validate  :sending_date, on: :create

  scope :by_customer_email, ->(email) { joins(:customer).where(Customer.arel_table[:email].eq(email)) }
  scope :not_sent, -> { where(status: statuses[:not_sent]) }
  scope :sent, -> { where(status: statuses[:sent]) }
  scope :customer_email_contains, ->(email) { by_customer_email(email) }
  scope :customer_first_name_contains, ->(name) { joins(:customer).where(Customer.arel_table[:first_name].matches(name)) }
  scope :customer_last_name_contains, ->(name) { joins(:customer).where(Customer.arel_table[:last_name].matches(name)) }
  scope :delivery_emails, -> { where(letter_type: letter_types[:delivery_email]) }

  # delay in minutes
  def send!(with_delay: 0)
    begin
      job = EmailsQueuesMailer.public_send(options[:type], self).deliver_later(wait: with_delay.minutes)
      update_attribute(:jid, job.job_id)
    rescue ArgumentError => error
      add_error(error.to_s)
      { flash: :alert, message: error.to_s }
    else
      { flash: :notice, message: 'Email sent!' }
    end
  end

  def mark_as_sent!
    sent!
    update(sent_at: DateTime.now, delivering_errors: nil)
  end

  def to_s
    "#{options[:type]}_#{id}"
  end

  def delete_from_sidekiq!
    sidekiq_jid = Sidekiq::ScheduledSet.new.find { |job| job.item['args'].first['job_id'] == jid }&.item&.dig('jid')

    return if sidekiq_jid.blank?

    Sidekiq::ScheduledSet.new.find_job(sidekiq_jid)&.delete
  end

  def add_error(error)
    update_attribute(:delivering_errors, delivering_errors << error)
  end

  private

  def sending_date
    errors.add(:sent_at, :already_sent) if cannot_be_sent?
  end

  def cannot_be_sent?
    persisted_emails = self.class.by_customer_email(recipient.email)

    persisted_emails.any? { |email| ((Time.now - email.created_at.to_time) / 1.hours) < 48 && email.delivery_email? }
  end
end
