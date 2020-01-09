class SalesLocationTimeline < ActiveRecord::Base
  belongs_to :sales_location
  belongs_to :states_timeline

  def self.for_location(location_id)
    joins(:sales_location).find_by(sales_locations: { id: location_id })
  end
end
