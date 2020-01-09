class FittingGarment < ActiveRecord::Base
  belongs_to :category
  has_many :fitting_garment_measurements, dependent: :destroy

  accepts_nested_attributes_for :fitting_garment_measurements, allow_destroy: false

  validates :name, :category, :order, presence: true
end
