class Value < ActiveRecord::Base
  has_many :category_param_values

  validates_uniqueness_of :title
end
