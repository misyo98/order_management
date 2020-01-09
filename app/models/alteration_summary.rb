class AlterationSummary < ActiveRecord::Base
  DELIVERY_METHODS = {
    'Courier'                         => :courier,
    'Appointment'                     => :appointment,
    'Wait for other items to arrive'  => :wait_for_arrive
  }.freeze

  NON_ALTERED_ITEMS = {
    'Collected'   => :collected,
    'At showroom' => :at_showroom,
    'All items altered' => :all_altered
  }.freeze

  REMAINING_ITEMS = {
    'No further items'                            => :no_further_items,
    'Only trigger after alteration is completed'  => :trigger_after_alteration,
    'Trigger one remaining'                       => :trigger_one_remaining,
    'Trigger all remaining'                       => :trigger_all_remaining
  }.freeze

  STATE_QUEUES = {
    to_be_altered:    'To be altered',
    to_be_updated:    'To be updated',
    to_be_invoiced:   'To be invoiced',
    invoiced:         'Invoiced',
    paid:             'Paid'
  }.freeze

  #State Machine for Fabric Statuses
  state_machine initial: :to_be_altered do

    # initial event for alterations that are now available to work with
    event :back_from_alteration do
      transition to_be_altered: :to_be_updated
    end

    event :will_be_invoiced do
      transition [:to_be_updated, :to_be_altered] => :to_be_invoiced
    end

    event :invoiced do
      transition to_be_invoiced: :invoiced
    end

    event :removed_invoice do
      transition invoiced: :to_be_invoiced
    end

    event :got_paid do
      transition invoiced: :paid
    end

    state :to_be_altered
    state :to_be_updated
    state :to_be_invoiced
    state :invoiced
    state :paid
  end

  enum delivery_method: %i(courier appointment wait_for_arrive)
  enum non_altered_items: %i(collected at_showroom all_altered)
  enum remaining_items: %i(no_further_items trigger_after_alteration trigger_one_remaining trigger_all_remaining)
  enum request_type: %i(alteration remake)

  belongs_to :profile
  belongs_to :updater, -> { with_deleted }, class_name: 'User'
  has_many :images, class_name: 'AlterationImage'
  has_many :alterations
  has_many :alteration_infos
  has_many :alteration_summary_services, dependent: :destroy, autosave: true
  has_many :alteration_services, through: :alteration_summary_services
  has_many :alteration_summary_line_items
  has_many :items, through: :alteration_summary_line_items, source: :line_item
  has_many :alteration_tailors, through: :alteration_summary_line_items, source: :alteration_tailor
  has_many :invoice_alteration_summaries
  has_many :invoices, through: :invoice_alteration_summaries

  accepts_nested_attributes_for :images, reject_if: :all_blank
  accepts_nested_attributes_for :alteration_services, reject_if: proc { |attr| attr['name'].blank? }

  delegate :first_name, :last_name, to: :updater, prefix: true, allow_nil: true

  serialize :line_item_ids, Array

  scope :with_includes, -> { includes(:alteration_infos, alteration_summary_line_items: [line_item: [:tailor]], profile: [:customer], alterations: [measurement: [category_param: :param]]) }

  scope :with_profile_includes, -> { includes(profile: [measurements: [alterations: [category_param_value: :value], adjustment_value: [:value],
    category_param: [:category, :param, values: [:value]],
    category_param_value: [:value]]]) }

  scope :due_date_gteq_date, ->(date) { where(arel_table[:requested_completion].gteq(date)) }
  scope :due_date_lteq_date, ->(date) { where(arel_table[:requested_completion].lteq(date)) }

  scope :by_alteration_tailor_name, -> (*tailor_names) { joins(:alteration_tailors).where(AlterationTailor.arel_table[:name].in(tailor_names)) }

  scope :alteration_send_gteq_date, -> (date) { joins(:items).where(LineItem.arel_table[:sent_to_alteration_date].gteq(date)) }
  scope :alteration_send_lteq_date, -> (date) { joins(:items).where(LineItem.arel_table[:sent_to_alteration_date].lteq(date)) }

  scope :alteration_back_gteq_date, -> (date) { joins(:items).where(LineItem.arel_table[:back_from_alteration_date].gteq(date)) }
  scope :alteration_back_lteq_date, -> (date) { joins(:items).where(LineItem.arel_table[:back_from_alteration_date].lteq(date)) }

  scope :customer_name_match, ->(name) { joins(profile: :customer).where(Customer.arel_table[:first_name].matches("%#{name}%").or(Customer.arel_table[:last_name].matches("%#{name}%"))) }

  scope :manufacturer_number_match, ->(number) { joins(:alteration_infos).where(AlterationInfo.arel_table[:manufacturer_code].matches("%#{number}%")) }

  scope :created_by_match, ->(name) { joins(alteration_infos: :author).where(User.arel_table[:first_name].matches("%#{name}%").or(User.arel_table[:last_name].matches("%#{name}%"))) }

  scope :list, -> {
    joins(:alteration_infos, :alteration_summary_line_items)
    .group('alteration_summaries.id').order(created_at: :desc)
  }

  scope :tailor_summaries, -> (tailor_id) {
    where(alteration_summary_line_items: { alteration_tailor_id: tailor_id })
  }

  scope :to_be_altered, -> { with_state(:to_be_altered) }

  scope :to_be_updated, -> { with_state(:to_be_updated) }

  scope :to_be_invoiced, -> { with_state(:to_be_invoiced) }

  scope :invoiced, -> { with_state(:invoiced) }

  scope :paid, -> { with_state(:paid) }

  scope :unique_summaries, -> {
    joins("LEFT JOIN alteration_summary_line_items AS asli ON alteration_summary_line_items.line_item_id = asli.line_item_id AND alteration_summary_line_items.id < asli.id")
    .where("asli.id IS NULL")
  }

  def self.ransackable_scopes(auth_object = nil)
    [:due_date_gteq_date, :due_date_lteq_date, :customer_name_match,
      :alteration_send_gteq_date, :alteration_send_lteq_date,
      :alteration_back_gteq_date, :alteration_back_lteq_date,
      :manufacturer_number_match, :created_by_match, :by_alteration_tailor_name]
  end

  def altered_categories
    get_categories.pluck('categories.name').uniq
  end

  def altered_category_ids
    get_categories.pluck('categories.id').uniq
  end

  def alteration_numbers
    @alteration_numbers ||= profile.alteration_number(alteration_infos.first.manufacturer_code.split(', '))
  end

  def update_amount(tailor_id)
    amount = alteration_services.joins(:alteration_service_tailors)
      .where(alteration_service_tailors: {alteration_tailor_id: tailor_id})
      .sum(:price)
    amount = amount * similar_items_count if similar_items_count > 1
    self.amount = amount
    self.service_updated_at = Time.now
    self.save
  end

  def current_invoice
    @current_invoice ||= invoices.invoiced.last || invoices.paid.last
  end

  def similar_items_count
    @similar_items_count ||= alteration_infos.first&.manufacturer_code&.split(', ')&.uniq&.count || 0
  end

  def summary_order
    alteration_summary_line_items.last&.line_item&.order_id
  end

  def latest_category_alteration?
    previous_category_alterations =
      profile.alteration_summaries.where(AlterationSummary.arel_table[:id].not_eq(id))
        .select { |summary| summary.alteration_infos.any? }
          .select { |summary| summary.altered_categories.any? { |category| category.in?(altered_categories) } }

    previous_category_alterations.map(&:created_at).all? { |date| date < created_at } ? 'yes' : 'no'
  end

  private

  def get_categories
    alterations.joins(measurement: [category_param: :category])
  end
end
