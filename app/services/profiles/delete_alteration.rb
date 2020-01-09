module Profiles
  class DeleteAlteration
    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(summary, delete_with_revert)
      @summary = summary
      @delete_with_revert = delete_with_revert
    end

    def call
      unless delete_with_revert.nil?
        alterations = actual_alterations

        alterations.each do |alteration|
          altered_measurement = summary.profile.measurements.find(alteration.measurement_id)

          if altered_measurement.adjustment_value_id && altered_measurement.adjustment_value_id != altered_measurement.category_param_value_id
            altered_measurement.update(adjustment_value_id: altered_measurement.category_param_value_id)
          elsif altered_measurement.post_alter_garment.present? && !altered_measurement.post_alter_garment.zero?
            altered_measurement.update(post_alter_garment: altered_measurement.post_alter_garment - alteration.value)
          end
        end
      end

      summary.alterations.destroy_all
      summary.alteration_infos.destroy_all
      summary.alteration_summary_line_items.destroy_all
      summary.destroy!
    end

    private

    attr_reader :summary, :delete_with_revert

    def actual_alterations
      summary.alterations.each_with_object([]) { |alteration, hash| hash << alteration if alteration.value.present?  }
    end
  end
end
