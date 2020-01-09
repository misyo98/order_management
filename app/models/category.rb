class Category < ActiveRecord::Base
  JACKET_NAME = 'Jacket'.freeze

  has_many :category_params
  has_many :params, through: :category_params
  has_many :fits
  has_many :customers, through: :fits

  validates_uniqueness_of :name

  scope :visible, -> { where(visible: true) }
  scope :invisible, -> { where(visible: false) }
  scope :dropdown_category, -> { find_by(name: 'Body shape & postures') }
  scope :jacket, -> { visible.find_by(name: JACKET_NAME) }
end
