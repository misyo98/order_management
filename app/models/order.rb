class Order < ActiveRecord::Base
  STATUSES = {
    'pending'     => :pending,
    'processing'  => :processing,
    'on-hold'     => :on_hold,
    'completed'   => :completed,
    'cancelled'   => :cancelled,
    'refunded'    => :refunded,
    'failed'      => :failed
  }.freeze
  CURRENCIES = %w(GBP SGD).freeze
  DAYS_INTERVAL = 14

  attr_accessor :submitter_id

  belongs_to :customer

  has_one  :payment_detail, dependent: :destroy
  has_one  :billing, as: :billable, dependent: :destroy
  has_one  :shipping, as: :shippable, dependent: :destroy

  has_many :line_items, inverse_of: :order, dependent: :destroy

  serialize :shipping_lines, Array
  serialize :tax_lines, Array
  serialize :fee_lines, Array
  serialize :coupon_lines, Array

  enum status: %i(pending processing on_hold completed cancelled refunded failed)

  delegate :first_name, :last_name, :email, :phone, :country, to: :billing, prefix: true, allow_nil: true
  delegate :country, :first_name, :last_name, :address_1, :address_2,
           :city, :state, :postcode, :company, to: :shipping, prefix: true, allow_nil: true

  before_create :check_if_first_order

  after_save :maybe_trigger_items_state, if: :status_changed?
  after_save :log_comment, if: :comment_changed?

  accepts_nested_attributes_for :line_items, :billing, :shipping, :payment_detail

  scope :paid, -> { where(arel_table[:status].in([statuses[:processing], statuses[:completed]])) }
  scope :with_items_with_states, ->(states) { joins(:line_items).where(LineItem.arel_table[:state].in(states)) }
  scope :actual_orders, -> {
    where.not(status: [statuses[:cancelled], statuses[:failed], nil])
  }

  class << self
    def filter_orders(options: {})
      query = nil
      options.each do |data_hash|
        date = Date.parse(data_hash[:date])
        until_date = date + DAYS_INTERVAL.days
        if query
          query = query.or(email_search_arel(emails: data_hash[:emails], date: date, date_until: until_date))
        else
          query = email_search_arel(emails: data_hash[:emails], date: date, date_until: until_date)
        end
      end
      joins(:billing).where(query)
    end

    private

    def email_search_arel(emails:, date:, date_until:)
      arel_table[:created_at].gteq(date).and(arel_table[:created_at].lteq(date_until))
      .and(billing_email(email: emails[0]).or(billing_email(email: emails[1])))
    end

    def billing_email(email:)
      Billing.arel_table[:email].eq(email)
    end
  end

  private

  def maybe_trigger_items_state
    if processing? || completed?
      line_items.each(&:chase_payment)
    end
  end

  def log_comment
    line_items.each { |item| item.logged_events.create(event: :comment_added, comment_body: comment, user_id: submitter_id) }
  end

  def check_if_first_order
    return unless customer

    self.first_order = true if customer.orders.actual_orders.count.zero?
  end
end
