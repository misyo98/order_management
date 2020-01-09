class ProfileCategory < ActiveRecord::Base
  UNSUBMITTED_STATES = %w[to_be_checked to_be_fixed to_be_reviewed to_be_submitted].freeze

  belongs_to :category
  belongs_to :profile
  belongs_to :author, class_name: 'User'
  belongs_to :fitting_garment

  has_many :history_events, class_name: 'ProfileCategoryHistory'

  enum status: { to_be_reviewed: 0, submitted: 1, confirmed: 2, to_be_fixed: 3, to_be_submitted: 4, to_be_checked: 5 }

  delegate :name, :visible, to: :category, prefix: true, allow_blank: true
  delegate :customer, to: :profile, prefix: true, allow_blank: true

  validates_uniqueness_of :category_id, scope: [:profile_id]

  scope :visible, -> { joins(:category).where(Category.arel_table[:visible].eq(true)) }
  scope :unsubmitted, -> { where.not(status: [statuses[:submitted], statuses[:confirmed]]) }
  scope :to_be_fixed, -> { where(status: statuses[:to_be_fixed]) }

  def unsubmitted_status?
    status.in?(UNSUBMITTED_STATES)
  end
end
