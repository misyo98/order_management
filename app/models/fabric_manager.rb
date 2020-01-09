class FabricManager < ActiveRecord::Base
  STATUSES = {
    out_of_stock: 'Out of stock',
    discontinued: 'Discontinued'
  }.freeze

  enum status: %i(out_of_stock discontinued)

  delegate :title, to: :fabric_brand, prefix: true, allow_nil: true
  delegate :title, to: :fabric_book, prefix: true, allow_nil: true

  belongs_to :fabric_brand
  belongs_to :fabric_book
  has_many :fabric_infos, -> { unscope(where: :deleted_at) }, primary_key: :manufacturer_fabric_code, foreign_key: :manufacturer_fabric_code

  validates :manufacturer_fabric_code, presence: true, uniqueness: true

  before_save :nulify_estimated_restock_date

  establish_connection(:remote_db) if !Rails.env.test?

  private

  def nulify_estimated_restock_date
    assign_attributes(estimated_restock_date: nil) if discontinued?
  end
end
