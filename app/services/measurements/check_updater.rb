module Measurements
  class CheckUpdater
    HEIGHT_CATEGORY_PARAM_ID = 1
    ALL_HEIGHT_CLUSTER = :all
    HEIGHT_CLUSTER_MAP = {
      0..55 => 55,
      55..59 => 59,
      59..63 => 63,
      63..67 => 67,
      67..71 => 71,
      71..75 => 75,
      75..79 => 79,
      79..83 => 83,
      83..87 => 87
    }.freeze

    include Statistics

    def initialize(params = {})
      @checks             = MeasurementCheck.where(category_param_id: params.fetch(:ids, []))
      @category_param_ids = checks.pluck(:category_param_id)
      @measurements       = Measurement.for_checks(category_param_ids).group_by(&:category_param_id)
    end

    def update
      grouped_checks = checks.group_by(&:category_param_id)

      measurements.each do |category_param_id, objects_array|
        check = grouped_checks[category_param_id].first
        values_hash = scrape_check_values(objects_array, check.percentile?, check.percentile_id)

        if check.percentile? && check.percentile_id == HEIGHT_CATEGORY_PARAM_ID
          values_hash.each do |upper_limit, values|
            next if upper_limit.blank?

            height_cluster = check.height_clusters.find_or_initialize_by(upper_limit: upper_limit)
            result = percentiles(values.reject(&:nan?), check.min_percentile, check.max_percentile)
            height_cluster.min = result[:min]
            height_cluster.max = result[:max]
            height_cluster.save
          end
          total_result = percentiles(values_hash.values.flatten.reject(&:nan?), check.min_percentile, check.max_percentile)
          check.update_column(:min, total_result[:min])
          check.update_column(:max, total_result[:max])
        else
          total_result = percentiles(values_hash.values.flatten.reject(&:nan?), check.min_percentile, check.max_percentile)
          check.update_column(:min, total_result[:min])
          check.update_column(:max, total_result[:max])
        end
        print '.'
      end
      true
    end

    private

    attr_reader :checks, :measurements, :category_param_ids

    def scrape_check_values(measurements, percentile, percentile_param_id)
      measurements.each_with_object({}) do |measurement, result|
        measurement = measurement.decorate

        if percentile && percentile_param_id == HEIGHT_CATEGORY_PARAM_ID
          percentile_measurement = measurement.profile&.find_measurement(percentile_param_id)&.decorate
          cluster = resolve_cluster(percentile_measurement)
          value = calculate_by_param(measurement: measurement, percentile_measurement: percentile_measurement)
        elsif percentile
          percentile_measurement = measurement.profile&.find_measurement(percentile_param_id)&.decorate
          cluster = ALL_HEIGHT_CLUSTER
          value = calculate_by_param(measurement: measurement, percentile_measurement: percentile_measurement)
        else
          cluster = ALL_HEIGHT_CLUSTER
          value = measurement.post_alter_garment_field
        end

        result[cluster].present? ? result[cluster] << value : result[cluster] = [value]
      end
    end

    def resolve_cluster(percentile_measurement)
      HEIGHT_CLUSTER_MAP.each { |range, upper_limit| return upper_limit if percentile_measurement.post_alter_garment_field.to_f.in?(range) }
      nil
    end

    def calculate_by_param(measurement:, percentile_measurement:)
      return Float::NAN unless percentile_measurement
      result = (measurement.post_alter_garment_field.to_f / percentile_measurement.post_alter_garment_field.to_f).round(2)
      return Float::NAN if result.infinite? || result.zero?
      result
    end
  end
end
