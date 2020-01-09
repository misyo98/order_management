class Fit < ActiveRecord::Base
  acts_as_paranoid
  
  enum fit: %i(slim singapore_slim regular classic self_slim self_regular)
  
  belongs_to :profile
  belongs_to :category

  validates_uniqueness_of :category_id, scope: [:profile_id]
end
