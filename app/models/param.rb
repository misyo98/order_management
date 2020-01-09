class Param < ActiveRecord::Base
  enum input_type: %i(digits values)

  has_many :category_params
  has_many :categories, through: :category_params

  # validates_uniqueness_of :title, :alias
end
