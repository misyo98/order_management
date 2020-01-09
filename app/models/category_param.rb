class CategoryParam < ActiveRecord::Base
  CATEGORY_TITLES = {
    shirt: 'Shirt',
    jacket: 'Jacket',
    height: 'Height',
    pants: 'Pants',
    waistcoat: 'Waistcoat',
    chinos: 'Chinos'
  }.freeze

  PARAM_TITLES = {
    height: 'Height (inches)',
    chest: 'Chest',
    thigh: 'Thigh',
    waistcoat_chest: 'Waistcoat Chest',
    waistcoat_waist: 'Waistcoat Waist',
    waistcoat_front_pointed: 'Waistcoat Front Length (pointed)',
    waistcoat_front_straight: 'Waistcoat Front Length (straight)',
    waistcoat_back_length: 'Waistcoat Back Length',
    waistcoat_1st_button: 'Waistcoat 1st Button Position'
  }.freeze

  acts_as_paranoid

  belongs_to :category
  belongs_to :param

  has_many  :values,    class_name: 'CategoryParamValue'
  has_one   :check,     class_name: 'MeasurementCheck'
  has_one   :allowance
  has_many  :measurement_validations
  has_many  :measurement_validation_dependencies, foreign_key: :depends_on_id
  has_many  :dependable_category_params, through: :measurement_validation_dependencies, source: :dependant

  delegate :min, :max, to: :check, allow_nil: true
  delegate :id, to: :category, prefix: true
  delegate :name, to: :category, prefix: true
  delegate :title, to: :param, prefix: true
  delegate :digits?, :values?, to: :param, prefix: true

  scope :find_param, ->(category, param) { joins(:param, :category).find_by(Category.arel_table[:name].matches("#{CATEGORY_TITLES[category]}").and(Param.arel_table[:title].matches("#{PARAM_TITLES[param]}"))) }

  scope :all_for_alterations, -> { joins(:category).where(Category.arel_table[:visible].eq(true)).all.includes(:category, :param) }

  scope :specific_for_alterations, ->(category_ids) { joins(:category).where(Category.arel_table[:visible].eq(true).and(Category.arel_table[:id].in(category_ids))).includes(:category, :param) }

  scope :find_categories, ->(category_param_ids:) { where(id: category_param_ids).pluck(:category_id).uniq }

  scope :by_param_name, ->(name) { joins(:param).where(Param.arel_table[:title].matches(name)) }

  scope :by_category_and_param_aliases, ->(category: , param: ) do
    joins(:category, :param).where(
      Category.arel_table[:parameterized_name].eq(category).and(
        Param.arel_table[:parameterized_name].eq(param)
      )
    )
  end

  default_scope -> { includes(:category, :param) }

  def to_s
    "#{category_name} - #{param_title}"
  end
end
