class FabricTab < ActiveRecord::Base
  belongs_to :fabric_category

  has_many :fabric_options, dependent: :destroy, inverse_of: :fabric_tab

  accepts_nested_attributes_for :fabric_options, allow_destroy: true

  validates :title, presence: true

  before_save :set_order

  establish_connection(:remote_db) if !Rails.env.test?

  amoeba do
    enable
  end

  private

  def set_order
    if order.nil? && fabric_category.present?
      increment(:order, fabric_category.fabric_tabs.map(&:order).compact.max.to_i + 1)
    end
  end
end
