class FabricOptionValue < ActiveRecord::Base
  belongs_to :fabric_option
  belongs_to :dropdown_list

  serialize :depends_on_option_value_ids, Array
  attribute :price, ActiveRecord::Type::Json.new

  attr_accessor :SGD, :GBP

  PREMIUM_SELECTION = {
    premium_all: 'All',
    premium_yes: 'Yes',
    premium_no: 'No'
  }.freeze

  MANUFACTURERS = {
    all_m: 'All manufacturers',
    old_m: 'Old (R)',
    new_m: 'New (D)'
  }.freeze

  TUXEDO_SELECTION = {
    tuxedo_all: 'All',
    tuxedo_yes: 'Yes',
    tuxedo_no: 'No'
  }.freeze

  OUTFITTER_SELECTION = {
    os_all: 'All',
    os_yes: 'Yes',
    os_no: 'No'
  }.freeze

  enum tuxedo: %i(tuxedo_all tuxedo_yes tuxedo_no)
  enum premium: %i(premium_all premium_yes premium_no)
  enum manufacturer: %i(all_m old_m new_m)
  enum outfitter_selection: %i(os_all os_yes os_no)

  validates :title, presence: true
  validates :manufacturer, presence: true

  scope :for_dropdown_list, -> { where(FabricOptionValue.arel_table[:dropdown_list_id].not_eq(nil)) }

  establish_connection(:remote_db) if !Rails.env.test?

  amoeba do
    enable
    nullify :depends_on_option_value_ids
  end

  before_save :set_order
  before_save :format_depends_on_array

  private

  def set_order
    if order.nil? && fabric_option.present?
      increment(:order, fabric_option.fabric_option_values.map(&:order).compact.max.to_i + 1)
    end
  end

  def format_depends_on_array
    formatted_array = depends_on_option_value_ids.each_with_object([]) { |option, array| array << option.to_i unless option.blank? }
    assign_attributes(depends_on_option_value_ids: formatted_array)
  end
end
