class FabricTier < ActiveRecord::Base
  has_many :fabric_tier_categories, dependent: :destroy, inverse_of: :fabric_tier
  has_many :fabric_infos

  accepts_nested_attributes_for :fabric_tier_categories, allow_destroy: true

  validates :title, presence: true
  validate :unique_tiers_categories

  establish_connection(:remote_db) if !Rails.env.test?

  private

  def unique_tiers_categories
    if fabric_tier_categories.map(&:fabric_category_id) != fabric_tier_categories.map(&:fabric_category_id).uniq
      errors.add(:already_selected_category, 'please be sure to add only one Tier Category per Fabric Category')
    end
  end
end
