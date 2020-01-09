class MeasurementCheck < ActiveRecord::Base
  VALUE_FIELDS = { 'Height Inches' => :garment_height_height_inches,
                   'Height CM' => :garment_height_height_cm,
                   'Chest - Body' => :garment_jacket_chest }.freeze
  NOT_NEEDED_CHECKS = %w(Knee).freeze

  enum percentile_of: %i(height chest knee thigh chinos_thigh shirt_chest)
  enum calculations_type: %i(percentile abs_value)

  belongs_to :category_param
  belongs_to :percentile_param, foreign_key: :percentile_id, class_name: 'CategoryParam'
  has_many :height_clusters, -> { order(upper_limit: :desc) }, class_name: 'MeasurementCheckHeightCluster', dependent: :destroy

  delegate :id, to: :percentile_param, prefix: true
  delegate :category_name, to: :category_param
  delegate :param_title, to: :category_param

  scope :for_checks_table, -> { joins(category_param: :param).where.not(Param.arel_table[:title].in(NOT_NEEDED_CHECKS)) }
  scope :without_blank_params, -> { where(arel_table[:category_param_id].not_eq(nil)) }
end
