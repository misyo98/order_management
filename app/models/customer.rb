class Customer < ActiveRecord::Base
  include Findable

  mount_uploader :avatar, ImageUploader

  has_many :orders
  has_many :line_items, through: :orders
  has_many :comments, class_name: 'ActiveAdmin::Comment', foreign_key: :resource_id, foreign_type: :resource_type

  has_one  :profile
  has_one  :billing,  as: :billable
  has_one  :shipping, as: :shippable

  belongs_to  :last_order, class_name: 'Order'

  delegate :id, to: :profile, prefix: true, allow_nil: true
  delegate :address_1, :address_2, :postcode, :phone, to: :billing, prefix: true, allow_nil: true
  delegate :address_1, :address_2, :city, :postcode, :country, to: :shipping, prefix: true, allow_nil: true
  delegate :created_at, to: :last_order, prefix: true, allow_nil: true

  accepts_nested_attributes_for :billing, :shipping

  before_create :set_token
  before_create :check_acquisition_channel

  delegate :first_name, :last_name, :phone, to: :billing, prefix: true, allow_nil: true

  scope :without_bots, -> { where.not(arel_table[:email].matches("%@163.com")) }

  scope :with_includes, -> {
    includes(:orders, profile: [:author, :images, :categories,
      measurements: [:measurement_issues, category_param_value: [:value], category_param: [:category, :param, :allowance, :check, values: :value],
      adjustment_value: [:value],
      alterations: [category_param_value: :value]]])
  }

  # scope :with_orders, -> { where.not(last_order_id: nil) }

  scope :with_specific_category, ->(category_id:) { joins(profile: [measurements: :category_param]).where(CategoryParam.arel_table[:category_id].eq(category_id)) }

  scope :with_paid_orders, ->(emails:) { where(email: emails).joins(orders: :payment_detail).where(PaymentDetail.arel_table[:paid].eq(true)) }

  scope :with_orders_in_date, ->(date:) { joins(:orders).where(Order.arel_table[:created_at].gteq(date).and(Order.arel_table[:created_at].lteq(date + 7.days))) }

  scope :call_list, -> { joins(:last_order).uniq.all.includes(:shipping, :billing) }

  scope :orders_created_at, ->(date) { where(Order.arel_table[:created_at].lteq(date)) }

  scope :with_order, ->(number) { joins(:orders).where(Order.arel_table[:number].eq(number.to_i)) }

  scope :profile_id_includes, ->(search='') {
     current_scope = self
     ids = []
     search.split(',').each do |id|
       ids << id
     end
     current_scope.joins(:profile).where(Profile.arel_table[:id].in(ids))
  }

  ransacker :categories, formatter: proc { |category_id|
      ids = with_specific_category(category_id: category_id).pluck(:id).uniq
      ids.any? ? ids : nil
    } do |parent|
    parent.table[:id]
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_token
    return if token.present?
    self.token = generate_token
  end

  class << self
    def ransackable_scopes(auth_object = nil)
      [:profile_id_includes, :with_order, :orders_created_at]
    end
  end

  private

  def generate_token
    SecureRandom.uuid.gsub(/\-/,'')
  end

  def check_acquisition_channel
    channel = Customers::AcquisitionChannel.fetch(email)

    if channel.present?
      self.acquisition_channel = channel
    end
  end
end
