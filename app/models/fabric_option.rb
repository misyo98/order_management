class FabricOption < ActiveRecord::Base
  belongs_to :fabric_tab
  belongs_to :dropdown_list

  has_many :fabric_option_values, dependent: :destroy, inverse_of: :fabric_option
  has_many :list_option_values, through: :dropdown_list, source: :fabric_option_values

  serialize :depends_on_option_value_ids, Array

  accepts_nested_attributes_for :fabric_option_values, allow_destroy: true

  BUTTON_TYPES = {
    dropdown_button: 'Dropdown',
    radio_button: 'Radio',
    checkbox_button: 'Checkbox',
    text_button: 'Text',
    price_button: 'Price'
  }.freeze

  OUTFITTER_SELECTION = {
    os_all: 'All',
    os_yes: 'Yes',
    os_no: 'No'
  }.freeze

  TUXEDO_SELECTION = {
    tuxedo_all: 'All',
    tuxedo_yes: 'Yes',
    tuxedo_no: 'No'
  }.freeze

  PREMIUM_SELECTION = {
    premium_all: 'All',
    premium_yes: 'Yes',
    premium_no: 'No'
  }.freeze

  FUSIBLE_SELECTION = {
    fusible_all: 'All',
    fusible_yes: 'Yes',
    fusible_no: 'No'
  }.freeze

  MANUFACTURERS = {
    all_m: 'All manufacturers',
    old_m: 'Old (R)',
    new_m: 'New (D)'
  }.freeze

  enum button_type: %i(dropdown_button radio_button checkbox_button text_button price_button)
  enum outfitter_selection: %i(os_all os_yes os_no)
  enum tuxedo: %i(tuxedo_all tuxedo_yes tuxedo_no)
  enum premium: %i(premium_all premium_yes premium_no)
  enum fusible: %i(fusible_all fusible_yes fusible_no)
  enum manufacturer: %i(all_m old_m new_m)

  validates :title, presence: true
  validates :button_type, presence: true
  validates :outfitter_selection, presence: true
  validates :premium, presence: true
  validates :fusible, presence: true
  validates :manufacturer, presence: true

  establish_connection(:remote_db) if !Rails.env.test?

  amoeba do
    enable
    nullify :depends_on_option_value_ids
  end

  before_save :set_order
  before_save :format_depends_on_array
  before_save :nullify_dropdown_list
  before_save :nullify_text_button_fields
  before_save :nullify_price_button_fields

  private

  def set_order
    if order.nil? && fabric_tab.present?
      increment(:order, fabric_tab.fabric_options.map(&:order).compact.max.to_i + 1)
    end
  end

  def format_depends_on_array
    formatted_array = depends_on_option_value_ids.each_with_object([]) { |option, array| array << option.to_i unless option.blank? }

    self.depends_on_option_value_ids = formatted_array
  end

  def nullify_dropdown_list
    self.dropdown_list_id = nil unless using_dropdown_list?
  end

  def nullify_text_button_fields
    unless text_button?
      self.max_characters = nil
      self.allowed_characters = nil
    end
  end

  def nullify_price_button_fields
    self.price = nil unless price_button?
  end
end
