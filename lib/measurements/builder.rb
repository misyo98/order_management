module Measurements
  module Builder
    extend self

    def build_measurements(object:, category_ids:)
      existing_ids = object.measurements.pluck(:category_param_id)
      params = CategoryParam.includes(:category)
                            .where(category_id: category_ids)
                            .joins(:category)
                            .order(:order)
      params.each { |category_param| object.measurements.build(category_param: category_param) unless category_param.id.in?(existing_ids) }
    end

    def build_images(object:, count:)
      (count - object.images.count).times { object.images.build }
    end

    def build_alterations(object:)
      object.measurements.each { |measurement| measurement.alterations.build }
    end

    def params(category_ids:)
      CategoryParam.where(category_id: category_ids)
                   .includes(:category, :param, :check, :allowance, 
                             values: :value)
    end
  end
end