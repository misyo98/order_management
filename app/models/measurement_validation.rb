class MeasurementValidation < ActiveRecord::Base
  belongs_to :category_param
  belongs_to :created_by,      -> { with_deleted }, class_name: 'User'
  belongs_to :last_updated_by, -> { with_deleted }, class_name: 'User'
  has_many :validation_parameters, inverse_of: :measurement_validation

  accepts_nested_attributes_for :validation_parameters

  amoeba do
    enable
    append comment: ' - Copy 1'
  end

  validates :category_param_id, :left_operand, :comparison_operator,
            :original_expression, :error_message, presence: true

  serialize :execution_errors, Array
  serialize :fits, Array
end
