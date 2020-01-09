class FabricInfo < ActiveRecord::Base
  TYPES = {
    'Stock' => :stock,
    'Cut-length' => :cut_length
  }.freeze

  MANUFACTURERS = {
    blank_m: '',
    old_m: 'Old (R)',
    new_m: 'New (D)'
  }.freeze

  LIMITED_FABRICS_ACCESS = %w[outfitter ops suit_placing senior_outfitter].freeze

  acts_as_paranoid

  enum fabric_type: %i(stock cut_length)
  enum manufacturer: %i(blank_m old_m new_m)

  has_many :enabled_fabric_categories, dependent: :destroy
  has_one :fabric_manager, -> { unscope(where: :deleted_at) }, primary_key: :manufacturer_fabric_code, foreign_key: :manufacturer_fabric_code
  belongs_to :fabric_brand, -> { unscope(where: :deleted_at) }
  belongs_to :fabric_book, -> { unscope(where: :deleted_at) }
  belongs_to :fabric_tier

  establish_connection(:remote_db) if !Rails.env.test?

  def limited_fabrics_access?
    role.in?(LIMITED_FABRICS_ACCESS)
  end
end
