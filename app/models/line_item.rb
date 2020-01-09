class LineItem < ActiveRecord::Base
  CATEGORY_KEYS =
    {
      'MADE-TO-MEASURE SUITS'       => ['Jacket', 'Pants'],
      'MADE-TO-MEASURE SHIRTS'      => ['Shirt'],
      'MADE-TO-MEASURE CHINOS'      => ['Chinos'],
      'MADE-TO-MEASURE WAISTCOATS'  => ['Waistcoat'],
      'MADE-TO-MEASURE TROUSERS'    => ['Pants'],
      'MADE-TO-MEASURE JACKETS'     => ['Jacket'],
      'MADE-TO-MEASURE OVERCOATS'   => ['Overcoat'],
      'GIFT CARD'                   => ['Gift'],
      'VOUCHERS'                    => ['Voucher'],
      'POSTAGE'                     => ['Postage'],
      'ACCESSORIES'                 => ['Accessory'],
      'NON-CUSTOM'                  => ['Non-custom'],
      'ALTERATION'                  => ['Alteration'],
      'SHIPPING'                    => ['Shipping'],
      'EXTRA AMOUNT'                => ['Extra Amount'],
      nil                           => ['n/a']
    }.freeze
  GIFT_CATEGORY =
    [
      'GIFT CARD',
      'VOUCHERS',
      'POSTAGE',
      'ACCESSORIES',
      'NON-CUSTOM'
    ].freeze
  FULL_SUIT_ITEMS = ['Jacket', 'Pants'].freeze
  SUIT_CATEGORY = 'MADE-TO-MEASURE SUITS'.freeze
  FABRIC_EVENTS = %i(none_fabric available_fabric unavailable_no_ordered_fabric unavailable_ordered_fabric out_of_stock_fabric).freeze
  STATIC_SCOPE_NAMES = %w(Change\ States).freeze
  STATIC_SCOPES = %w(change_states).freeze
  STATES_EDITABLE_BY_TAILORS = %w(alteration_requested being_altered).freeze
  FORBIDDEN_TO_TAILORS_STATE_BUTTONS = %i(wait_for_other_items send_delivery_appt_email prepare_shipment).freeze
  STATE_QUEUES = {
    payment_pending:              'Payment pending',
    new:                          'New',
    new_to_be_measured:           'New - To be measured',
    no_measurement_profile:       'Manufacturing - No profile',
    to_be_checked_profile:        'Manufacturing - To be checked profile',
    to_be_fixed_profile:          'Manufacturing - To be fixed profile',
    to_be_reviewed_profile:       'Manufacturing - To be reviewed profile',
    to_be_submitted_profile:      'Manufacturing - To be submitted profile',
    submitted_profile:            'Manufacturing - No manufacturer order',
    manufacturer_order_created:   'Manufacturing - Cut-length not ordered',
    fabric_ordered:               'Manufacturing - Cut-length ordered',
    fabric_received:              'Manufacturing - Fabric available, ready to submit',
    item_out_of_stock:            'Manufacturing - Out of Stock',
    waiting_for_confirmation:     'Waiting for fit confirmation',
    fit_confirmed:                'Fit confirmed',
    confirmed_profile:            'Manufacturing - Confirmed profile',
    manufacturing:                'Manufacturing - Item submitted',
    inbound_shipping:             'Inbound shipping',
    inbounding:                   'Dispatch to showroom',
    single_at_office:             'At office - No other items in progress',
    last_at_office:               'At office - Other items in progress, all at office',
    partial_at_office:            'At office - Other items in progress, not all at office',
    waiting_for_items:            'At office - Waiting for other items',
    waiting_for_items_alteration: 'At office - Waiting for other items (Alteration / Remake)',
    delivery_email_sent:          'At office - Delivery email sent',
    delivery_arranged:            'At office - Delivery arranged',
    shipment_preparation:         'At office - Shipment preparation',
    shipped_unsubmitted:          'ERROR - Measurement status changed to "saved"',
    shipped_waiting_confirmation: 'Shipped, fit not confirmed',
    shipped_confirmed:            'Shipped, fit confirmed',
    alteration_appt_arranged:     'Alteration appointment arranged',
    alteration_requested:         'Alteration requested',
    remake_requested:             'Remake requested',
    being_altered:                'Being Altered',
    completed:                    'Completed',
    cancelled:                    'Cancelled',
    refunded:                     'Fully refunded',
    remade:                       'Remade',
    deleted_item:                 'Deleted'
  }.freeze
  RC_STATES = {
    not_created:  'Not Created',
    created:      'Created',
    checked:      'Checked',
    submitted:    'Submitted'
  }.freeze
  FABRIC_STATUSES = {
    none:                     'None',
    available:                'Available',
    unavailable_no_ordered:   'Unavailable - Not Ordered',
    unavailable_ordered:      'Unavailable - Ordered',
    out_of_stock:             'Out of stock'
  }.freeze
  COUNTRY_TO_CURRENCY = {
    'GB' => 'GBP',
    'SG' => 'SGD'
  }.freeze
  DELIVERY_METHODS = {
    'appointment' => 'Appointment',
    'wait_for_arrive' => 'Wait for other items to arrive',
    'courier' => 'Courier'
  }.freeze
  NOT_PROGRESS_STATES = %i(new payment_pending completed).freeze
  DELETED_ITEM_STATE = 'deleted_item'.freeze
  WAITING_STATE = 'waiting_for_confirmation'.freeze
  INACTIVE_STATES = %w(refunded remade deleted_item completed cancelled).freeze
  SHIPPED_CONFIRMED_STATE = 'shipped_confirmed'.freeze
  WAITING_OTHERS_STATES = %w(waiting_for_items_alteration waiting_for_items).freeze
  ALTERAION_BACK_STATES = %w(partial_at_office last_at_office single_at_office).freeze
  BEING_ALTERED_STATE = 'being_altered'.freeze
  FABRIC_CODE = 'Fabric Code'.freeze
  MANUFACTURERS = {
    blank_manufacturer: '',
    old_manufacturer: 'Old (R)',
    new_manufacturer: 'New (D)'
  }.freeze
  FABRIC_TO_ORDER_STATES = %w(no_measurement_profile to_be_checked_profile to_be_fixed_profile to_be_reviewed_profile to_be_submitted_profile
                              submitted_profile confirmed_profile new fit_confirmed shipped_unsubmitted).freeze

  include StatesValidator, EventValidator, OrderStateMachine, Askable, DateCalculator

  attr_accessor :submitter_id

  acts_as_paranoid

  has_paper_trail on: [:update], only: [:meta]

  enum m_order_status: %i(not_created created checked submitted)
  enum non_altered_items: %i(collected at_showroom all_altered)
  enum manufacturer: %i(blank_manufacturer old_manufacturer new_manufacturer)

  belongs_to :order, inverse_of: :line_items
  belongs_to :product
  belongs_to :sales_person, -> { with_deleted }, class_name: 'User'
  belongs_to :sales_location
  belongs_to :courier, class_name: 'CourierCompany', foreign_key: :courier_company_id
  belongs_to :tailor, class_name: 'AlterationTailor', foreign_key: :alteration_tailor_id
  belongs_to :deduction_ops_person, class_name: 'User'
  belongs_to :deduction_sales_person, class_name: 'User'

  has_many :fabrics, -> { unscope(where: :deleted_at) }, class_name: 'FabricInfo', primary_key: :fabric_code_value, foreign_key: :manufacturer_fabric_code
  has_many :logged_events, class_name: 'LineItemStateTransition'
  has_many :emails, class_name: 'EmailsQueue', foreign_key: :subject_id
  has_one  :real_cog, class_name: 'RealCog', primary_key: :m_order_number, foreign_key: :manufacturer_id
  has_many :alteration_summary_line_items
  has_many :alteration_summaries, through: :alteration_summary_line_items
  has_many :refunds
  has_many :line_item_tags
  has_many :tags, through: :line_item_tags

  delegate  :number, :created_at, :status, :billing_first_name, :paid_date, :completed_at,
            :billing_last_name, :shipping_country, :billing_email, :billing_phone, :total,
            :total_line_items_quantity, :currency, :customer_id, :customer, :shipping_company,
            :billing_country, :shipping_first_name, :shipping_last_name, :shipping_address_1,
            :shipping_address_2, :shipping_city, :shipping_state, :shipping_postcode, :total_tax,
            :note, :coupon_lines, to: :order, prefix: true
  delegate :category, :title, :sku, to: :product, prefix: true, allow_nil: true
  delegate :cogs_rc_usd, to: :real_cog, prefix: true, allow_nil: true
  delegate :first_name, :last_name, to: :sales_person, prefix: true, allow_nil: true
  delegate :name, :showroom_address, :delivery_calendar_link, :email_from, to: :sales_location, prefix: true, allow_nil: true
  delegate :tracking_link, :name, to: :courier, prefix: true, allow_nil: true

  validates_uniqueness_of :m_order_number, allow_blank: true, unless: :item_in_remake
  validates :amount_refunded, numericality: { less_than_or_equal_to: :valid_price }

  serialize :variations, Array
  serialize :meta, Array
  serialize :remake_category, Array

  scope :with_index_includes, -> { joins(:order).includes(:product, :sales_person, :sales_location, :tags) }
  #exists because somehow including relation :fabrics breaks the search by dates on the accounting page
  scope :with_accounting_includes, -> { includes(:real_cog, :product, :sales_person, :sales_location, :order) }
  scope :multiple_item, -> { where(arel_table[:quantity].gteq(2)) }
  scope :order_number_matches, ->(number) { joins(:order).where(Order.arel_table[:number].matches("%#{number}%")).uniq }
  scope :first_name_matches, ->(name) { joins(order: :billing).where(Billing.arel_table[:first_name].matches("%#{name}%")).uniq }
  scope :last_name_matches, ->(name) { joins(order: :billing).where(Billing.arel_table[:last_name].matches("%#{name}%")).uniq }
  scope :email_matches, ->(email) { joins(order: :billing).where(Billing.arel_table[:email].matches("%#{email}%")).uniq }
  scope :manufacturer_order_number_matches, ->(number) { where(arel_table[:manufacturer_order_number].matches("%#{number}%")) }
  scope :category_in, ->(name) { joins(:product).where(Product.arel_table[:category].matches("%#{name}%")) }
  scope :change_states, -> { all }
  scope :with_categories, ->(categories) { joins(:product).where(Product.arel_table[:category].in(convert_to_product_categories(categories))).uniq }
  scope :status_in, ->(states) { with_states(states) }
  scope :without_deleted, -> { where.not(state: DELETED_ITEM_STATE) }
  scope :for_customer, ->(customer_id) { joins(:order).where(Order.arel_table[:customer_id].eq(customer_id)) }
  scope :without_deleted, -> { where.not(state: DELETED_ITEM_STATE) }
  scope :remindable, -> { where(send_reminders: true) }
  scope :active_state, -> { without_states(INACTIVE_STATES) }
  scope :shipped_confirmed_state, -> {
    joins(:logged_events, order: {customer: :profile})
    .where(state: SHIPPED_CONFIRMED_STATE, line_item_state_transitions: {to: SHIPPED_CONFIRMED_STATE})
    .where.not(profiles: {id: nil})
  }
  scope :alteration_back, -> { with_states(ALTERAION_BACK_STATES).where.not(back_from_alteration_date: nil) }
  scope :being_altered_state, -> { with_states(BEING_ALTERED_STATE) }
  scope :tailor_items, -> (tailor_id) { where(alteration_tailor_id: tailor_id) }
  scope :sent_to_tailor_week_ago_or_more, -> { where(arel_table[:sent_to_alteration_date].lteq(5.day.ago)) }
  scope :for_locations, ->(sales_location_ids) { where(arel_table[:sales_location_id].in(sales_location_ids)) }
  scope :find_in_meta, -> (name) { where("meta LIKE ?", "%#{name}%") }
  scope :paid_or_create_date_gteq, -> (start_date) {
    joins(:order).where(Order.arel_table[:paid_date].gteq(start_date).or(Order.arel_table[:created_at].gteq(start_date)))
  }
  scope :paid_or_create_date_lteq, -> (end_date) {
    joins(:order).where(Order.arel_table[:paid_date].lteq(end_date).or(Order.arel_table[:created_at].lteq(end_date)))
  }
  scope :tag_name_matches, -> (name) { joins(:tags).where(Tag.arel_table[:name].matches("%#{name}%")) }
  scope :all_fabrics_to_order, -> {
    joins(:fabrics)
    .where(arel_table[:state].in(FABRIC_TO_ORDER_STATES)
      .and(
        FabricInfo.arel_table[:fabric_type].eq(FabricInfo.fabric_types[:cut_length])
      )
      .or(
        arel_table[:state].eq(:manufacturer_order_created)
        .and(
          FabricInfo.arel_table[:fabric_type].eq(FabricInfo.fabric_types[:cut_length])
        )
      )
    ).uniq.order(id: :desc)
  }
  scope :triggered_into_production, -> { without_states(NOT_PROGRESS_STATES + INACTIVE_STATES) }

  after_update :log_comment, if: :comment_field_changed?
  after_update :log_ordered_fabric, if: :ordered_fabric_changed?
  after_update :log_fabric_code, if: :fabric_code_value_changed?
  after_update :update_alteration_summary_line_item_tailor, if: :alteration_tailor_id_changed?
  after_update :update_alteration_summary_line_item_sent_date, if: :sent_to_alteration_date_changed?
  after_update :update_alteration_summary_line_item_back_date, if: :back_from_alteration_date_changed?
  before_save  :upcase_fabric_code, :update_meta_fabric_code, if: :fabric_code_value_changed?
  after_create :set_fabric_code_value

  def self.by_location_or_country(sales_location_ids:, country:)
    if sales_location_ids.any?
      for_locations(sales_location_ids).order('orders.id desc')
    else
      for_country(country: country).order('orders.id desc')
    end
  end

  def self.for_country(country:)
    if country == 'SG'
      where(Order.arel_table[:currency].eq('SGD'))
    else
      where(Order.arel_table[:currency].not_eq('SGD'))
    end
  end

  def self.with_resolved_locations(sales_location_ids, with_nil)
    if with_nil
      where(arel_table[:sales_location_id].in(sales_location_ids).or(arel_table[:sales_location_id].eq(nil)))
    else
      where(arel_table[:sales_location_id].in(sales_location_ids))
    end
  end

  def self.ransackable_scopes(auth_object = nil)
    [:order_number_matches, :first_name_matches, :last_name_matches, :email_matches, :manufacturer_order_number_matches,
      :category_in, :status_in, :full_name_matches, :find_in_meta, :tag_name_matches, :paid_or_create_date_gteq,
      :paid_or_create_date_lteq]
  end

  def self.full_name_matches(name)
    splitted_name = name.split(' ')
    query = nil

    case splitted_name.size
    when 1
      query = name_matcher(splitted_name.first)
    else
      splitted_name.each_with_index do |name_part, index|
        if index.zero?
          query = name_matcher(name_part)
        else
          query = query.and(name_matcher(name_part))
        end
      end
    end

    joins(order: :billing).where(query).uniq
  end

  def self.name_matcher(name)
    Billing.arel_table[:first_name].matches("%#{name}%").or(Billing.arel_table[:last_name].matches("%#{name}%"))
  end

  #State Machine for Fabric Statuses
  state_machine :fabric_state, namespace: :fabric do
    event :available do
      transition any => :available
    end

    event :unavailable_ordered do
      transition any => :unavailable_ordered
    end

    event :out_of_stock do
      transition any => :out_of_stock
    end

    event :unavailable_no_ordered do
      transition any => :unavailable_no_ordered
    end

    event :none do
      transition any => :none
    end

    state :none
    state :available
    state :unavailable_no_ordered
    state :unavailable_ordered
    state :out_of_stock

    after_transition any => :out_of_stock do |item, transition|
      user_id = transition.args.last.delete(:user_id)
      item.got_out_of_stock(user_id: user_id)
    end

    after_transition any => :unavailable_ordered do |item, transition|
      item.update(fabric_ordered_date: DateTime.now)
    end
  end

  #Array with categories is returned
  def local_category
    CATEGORY_KEYS[product_category] || ['n/a']
  end

  def gift_category?
    product_category.in?(GIFT_CATEGORY)
  end

  def fabric
    return nil unless fabrics.any?
    @fabric ||= fabrics.select { |fabric| fabric.valid_from.to_date <= order_date.to_date }.max_by(&:valid_from)
  end

  def order_date
    date = order_paid_date || order_created_at
    I18n.l(date, format: :order_date) if date
  end

  def is_delayed?
    return @is_delayed if defined?(@is_delayed)

    timeline = StatesTimeline.find_by(state: state)

    return false unless timeline&.from_event

    start_date =
      case timeline.from_event
      when 'order_date'
        order_date.to_date
      else
        logged_events.last_event(timeline.from_event)&.created_at
      end

    return false unless start_date

    @is_delayed = too_far_apart?(start_date, Date.today, timeline.resolve_allowed_time(sales_location_id, order_currency),
                                 timeline.working_days?)
  end

  def confirm_profile_category_fit
    order.customer.profile.with_categories(local_category).each(&:confirmed!)
  end

  def trigger_waiting_items
    order.line_items.with_categories(local_category).with_states(WAITING_STATE).each(&:fit_confirmed)
  end

  def other_items_in_progress?
    order.line_items.where.not(id: id).without_states(NOT_PROGRESS_STATES).any?
  end

  def clear_shipment_details
    update!(courier_company_id: nil, alteration_tailor_id: nil,
            outbound_tracking_number: nil, delivery_appointment_date: nil)
  end

  def trigger_shipment_preparation_or_delivery_email(state)
    order.line_items.with_states(WAITING_OTHERS_STATES).find_each do |order_item|
      order_item.public_send(state, skip_email: true)
    end
  end

  def set_appointment_date(day)
    update_attribute(:delivery_appointment_date, day)
  end

  def log_resend_delivery_email
    logged_events.create(event: :delivery_email_resent,
                         from: :delivery_email_sent,
                         to: :delivery_email_resent,
                         user_id: submitter_id)
  end

  def items_with_same_category
    @items_with_same_category ||= order.line_items.joins(:product).where(Product.arel_table[:category].eq(product_category))
  end

  def copied!
    update_attribute(:copied, true) unless copied?
  end

  def last_delivery_email
    @last_delivery_email ||= emails.delivery_emails.last
  end

  def no_measurement_profile?
    measurement_category_statuses.count != local_category.count
  end

  def measurement_profile_unconfirmed?
    measurement_category_statuses.any? { |status| status != ProfileCategory.statuses[:confirmed] }
  end

  def current_summary
    alteration_summaries.with_state(:to_be_altered).last
  end

  def measurement_profile_to_be_checked?
    @measurement_profile_to_be_checked ||= measurement_category_statuses.any? do |status|
      status == ProfileCategory.statuses[:to_be_checked]
    end
  end

  def measurement_profile_to_be_fixed?
    return false if measurement_profile_to_be_checked?

    measurement_category_statuses.any? { |status| status == ProfileCategory.statuses[:to_be_fixed] }
  end

  def measurement_profile_to_be_reviewed?
    return false if measurement_profile_to_be_fixed?

    measurement_category_statuses.any? { |status| status == ProfileCategory.statuses[:to_be_reviewed] }
  end

  def measurement_profile_to_be_submitted?
    return false if measurement_profile_to_be_reviewed?

    measurement_category_statuses.all? { |status| status == ProfileCategory.statuses[:to_be_submitted] }
  end

  private

  def valid_price
    (total.to_f / 100).round(2)
  end

  def upcase_fabric_code
    self.fabric_code_value = fabric_code_value.upcase
  end

  def update_meta_fabric_code
    fabric_code = meta.detect{ |h| h['key'] == FABRIC_CODE }
    if fabric_code
      meta.map do |field|
        field['value'] = fabric_code_value if field['key'] == FABRIC_CODE
      end
    else
      self.meta << {
        'key'   => FABRIC_CODE,
        'value' => fabric_code_value,
        'label' => FABRIC_CODE
      }
    end
  end

  def set_fabric_code_value
    fabric_value = meta&.detect { |meta| meta['key'] == 'Fabric Code' }&.dig('value')

    update_column(:fabric_code_value, fabric_value) if fabric_value
  end

  def measurement_category_statuses
    return [] unless order.customer&.profile

    @measurement_category_statuses ||= order.customer.profile.with_categories(local_category).pluck(:status)
  end

  def self.convert_to_product_categories(categories)
    categories.inject([]) do |product_categories, category|
      CATEGORY_KEYS.each do |product_category, categories_array|
        product_categories << product_category if category.in? categories_array
      end
      product_categories
    end
  end

  def change_order_status_to_created
    created!
  end

  def change_fabric_status_to_available
    is_available_fabric
  end

  def fabric_is_available?
    fabric&.stock?
  end

  def fabric_is_cut_length?
    fabric&.cut_length?
  end

  def other_items_at_office?
    order.line_items.all? { |item| item.partial_at_office? || item.waiting_for_items? }
  end

  # method for setting user_id for state event history(audit_trail)
  def user_id(transition)
    user_id = transition.args.last[:user_id] if transition.args.present?
    user_id ||= 0
  end

  # method for setting tailor_id for state event history(audit_trail)
  def tailor_id(transition)
    tailor_id = alteration_tailor_id if transition.event == :sent_to_alterations_tailor
  end

  # method for setting courier_company_id for state event history(audit_trail)
  def courier_id(transition)
    courier_id = courier_company_id if transition.event == :ship_items
  end

  def log_comment
    logged_events.create(event: :comment_added, comment_body: comment_field, user_id: submitter_id)
  end

  def log_fabric_code
    logged_events.create(event: :fabric_code_updated, from: fabric_code_value_was, to: fabric_code_value, user_id: submitter_id)
  end

  def log_ordered_fabric
    decorator = LineItemCsvDecorator.new(self)

    logged_events.create(
      event: :ordered_fabric_updated,
      from: decorator.yes_or_no(ordered_fabric_was),
      to: decorator.yes_or_no(ordered_fabric),
      user_id: submitter_id
    )
  end

  def fit_confirmed?
    return false unless order&.customer&.profile
    categories = order.customer.profile.categories.select { |profile_category| profile_category.category_name.in? local_category }
    categories.count == local_category.count && categories.all?(&:confirmed?)
  end

  def item_in_remake
    remake || remade?
  end

  private

  def update_alteration_summary_line_item_tailor
    alteration_summary_line_items.last&.update_column(:alteration_tailor_id, alteration_tailor_id)
  end

  def update_alteration_summary_line_item_sent_date
    alteration_summary_line_items.last&.update_column(:sent_to_alteration_date, sent_to_alteration_date)
  end

  def update_alteration_summary_line_item_back_date
    alteration_summary_line_items.last&.update_column(:back_from_alteration_date, back_from_alteration_date)
  end
end
