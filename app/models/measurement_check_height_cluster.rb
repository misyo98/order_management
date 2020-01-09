class MeasurementCheckHeightCluster < ActiveRecord::Base
  CLUSTERS = [55, 59, 63, 67, 71, 75, 79, 83].freeze

  belongs_to :measurement_check

  scope :closest_by_height, -> (height) do
    unscope(:order).order("abs(measurement_check_height_clusters.upper_limit - #{height})").order(upper_limit: :desc)
  end
end
