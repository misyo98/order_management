class FabricCategory < ActiveRecord::Base

  has_many :fabric_tabs, dependent: :destroy, inverse_of: :fabric_category
  has_many :fabric_options, through: :fabric_tabs

  attribute :tuxedo_price, ActiveRecord::Type::Json.new

  accepts_nested_attributes_for :fabric_tabs, allow_destroy: true

  validates :title, presence: true, uniqueness: true

  establish_connection(:remote_db) if !Rails.env.test?

  amoeba do
    enable
  end

  before_save :nulify_price_for_non_tuxedo

  private

  def nulify_price_for_non_tuxedo
    assign_attributes(tuxedo_price: nil) unless tuxedo
  end
end
