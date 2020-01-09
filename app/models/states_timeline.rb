class StatesTimeline < ActiveRecord::Base
  ALLOWED_EVENTS = %i(order_date trigger_manufacturing at_office alteration_requested 
                      ship_items fit_confirmed remake_requested).freeze
  SINGAPORE_CURRENCY = 'SGD'.freeze
  DEFAULT_ALLOWED_TIME = 1

  has_many :sales_location_timelines

  accepts_nested_attributes_for :sales_location_timelines, allow_destroy: true

  enum time_unit: %i(days working_days)

  validates :state, uniqueness: true

  def allowed_time_for_country(currency)
    allowed_time = 
      case currency
      when SINGAPORE_CURRENCY
        allowed_time_sg
      else
        allowed_time_uk
      end

    allowed_time || DEFAULT_ALLOWED_TIME
  end

  def resolve_allowed_time(sales_location_id, currency)
    location_time = sales_location_timelines.for_location(sales_location_id)&.allowed_time
    country_time = allowed_time_for_country(currency)

    location_time || country_time
  end
end
