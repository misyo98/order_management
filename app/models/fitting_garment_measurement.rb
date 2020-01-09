class FittingGarmentMeasurement < ActiveRecord::Base
  belongs_to :fitting_garment
  belongs_to :category_param
end
