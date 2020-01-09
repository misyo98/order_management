class Measurement < ActiveRecord::Base
  belongs_to :profile
  belongs_to :category_param
  belongs_to :category_param_value
  belongs_to :adjustment_value, class_name: 'CategoryParamValue'
  belongs_to :fitting_garment_measurement

  validates_uniqueness_of :category_param_id, scope: [:profile_id]

  has_many   :alterations, dependent: :destroy
  has_many :measurement_issues, as: :issueable
  has_one :error_confirmation, dependent: :destroy, inverse_of: :measurement

  accepts_nested_attributes_for :alterations
  accepts_nested_attributes_for :error_confirmation, reject_if: :all_blank

  delegate :category, to: :category_param, allow_nil: true
  delegate :param, to: :category_param, allow_nil: true
  delegate :name, :id, to: :category, prefix: true
  delegate :title, to: :param, prefix: true
  delegate :order, to: :category_param
  delegate :value_title, to: :category_param_value
  delegate :adjustment_value_title, to: :adjustment_value

  default_scope { joins(category_param: :category).order(CategoryParam.arel_table[:order]) }

  scope :for_alterations, ->(id:, start:, end_date:) { joins(:profile).where(created_profiles(author_id: id, start: start, end_date: end_date))
    .includes(:alterations, category_param: [:category, :param]) }

  scope :uniq_submitted_categories, ->(id:, start:, end_date:) { joins(:profile, category_param: :category).where(created_profiles(author_id: id, start: start, end_date: end_date))
    .where(:'categories.visible' => true).pluck(:'profiles.id', :'categories.id').uniq }

  scope :for_checks, ->(category_param_ids) { joins(profile: :categories)
                                              .where(ProfileCategory.arel_table[:status].eq(ProfileCategory.statuses[:confirmed]))
                                              .where(category_param_id: category_param_ids) }

  private

  class << self
    def profile
      Profile.arel_table
    end

    def created_profiles(author_id:, start:, end_date:)
      profile[:author_id].eq(author_id).and(profile[:created_at].gteq(start).and(profile[:created_at].lteq(end_date)))
    end
  end
end
