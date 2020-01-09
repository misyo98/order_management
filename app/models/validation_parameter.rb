class ValidationParameter < ActiveRecord::Base
  belongs_to :measurement_validation, inverse_of: :validation_parameters

  validates :name, :original_expression, presence: true
end
