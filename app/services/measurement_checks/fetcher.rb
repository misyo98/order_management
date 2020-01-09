module MeasurementChecks
  class Fetcher
    def self.fetch(*attrs)
      new(*attrs).fetch
    end

    def initialize(height)
      @height = height
    end

    def fetch
      MeasurementCheck.without_blank_params.height.percentile.each_with_object({}) do |check, result|
        height_cluster = check.height_clusters.closest_by_height(height).first

        result[check.category_param_id] = {
          min: height_cluster&.min || check.min,
          max: height_cluster&.max || check.max
        }
      end
    end

    private

    attr_reader :height
  end
end
