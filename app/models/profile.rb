class Profile < ActiveRecord::Base
  acts_as_paranoid

  has_many   :measurements
  has_many   :images,               class_name: 'ProfileImage'
  has_many   :fits,                 dependent: :destroy
  has_many   :alteration_infos,     dependent: :destroy
  has_many   :alteration_summaries #, dependent: :destroy
  has_many   :categories,           class_name: 'ProfileCategory'
  has_many   :measurement_issues, as: :issueable

  belongs_to :customer
  belongs_to :author, -> { with_deleted },    class_name: 'User'
  belongs_to :submitter, -> { with_deleted }, class_name: 'User'

  delegate :first_name, :last_name, :email, to: :author,    prefix: true, allow_nil: true
  delegate :first_name, :last_name, :email, to: :submitter, prefix: true, allow_nil: true
  delegate :first_name, :last_name, :email, :id, :full_name,
           to: :customer,  prefix: true, allow_nil: true

  accepts_nested_attributes_for :measurements, :fits
  accepts_nested_attributes_for :images, reject_if: :all_blank

  scope :outfitter_submissions, ->(author_id:, start_date:, end_date:) { where(author_id: author_id, created_at: start_date..end_date) }

  scope :with_includes, -> { includes(measurements: [
      alterations: [category_param_value: :value],
      adjustment_value: [:value],
      category_param: [:category, :param, values: [:value]],
      category_param_value: [:value]
    ]) }

  scope :with_category, ->(category) { joins(categories: :category).where(Category.arel_table[:name].eq(category)) }
  scope :to_be_fixed, -> { joins(:categories).merge(ProfileCategory.to_be_fixed) }

  def find_measurement(id)
    measurements.find_by(category_param_id: id)
  end

  def any_alterations?
    measurements.joins(:alterations).pluck(:'alterations.id').any?
  end

  def categories_with_states(states: [])
    categories.joins(:category).where(ProfileCategory.arel_table[:status].in(ProfileCategory.statuses.values_at(*states)))
              .where(Category.arel_table[:visible].eq(true))
              .pluck('categories.name').uniq
  end

  def category_status(category)
    categories.joins(:category).find_by(Category.arel_table[:name].eq(category))&.status
  end

  def with_categories(search_categories)
    categories.joins(:category).where(Category.arel_table[:name].in(search_categories))
  end

  def have_categories_with_state?(item_categories:, states: [])
    persisted_categories = categories.joins(:category).where(ProfileCategory.arel_table[:status].in(ProfileCategory.statuses.values_at(*states)))
                                     .where(Category.arel_table[:name].in(item_categories))
                                     .pluck('categories.name').uniq
    (item_categories - persisted_categories).empty?
  end

  def alteration_number(manufacturer_numbers)
    manufacturer_numbers.inject({}) do |response, number|
      response[number] = get_number_counter(number)
      response
    end
  end

  def max_alterations
    @max_alterations ||= alteration_summaries.joins(:alteration_infos).group('alteration_infos.category_id').count.values.max || 0
  end

  private

  def get_number_counter(number)
    alteration_infos.where(number_query(number)).pluck(:alteration_summary_id).uniq.count
  end

  def number_query(number)
    AlterationInfo.arel_table[:manufacturer_code].matches("%#{number}%")
  end
end
