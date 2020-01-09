module Exporters
  class Objects::FittingGarments < Exporters::Base
    DEFAULT_HEADERS = ['Order', 'Name', 'Category', 'Country'].freeze

    def initialize
      @fitting_garments = FittingGarment.includes(:category, :fitting_garment_measurements)
                                        .order(order: :asc)
                                        .all
      @categories = Category.select(:id, :name)
                            .includes(category_params: :param)
                            .where(
                              Category.arel_table[:name].not_in([
                                'Body shape & postures', 'Height'
                              ])
                            )
    end

    private

    attr_reader :fitting_garments, :categories

    def process
      CSV.generate(headers: true) do |csv|
        csv << build_headers

        fitting_garments.each do |fitting_garment|
          csv << ([fitting_garment.order, fitting_garment.name, fitting_garment.category.name, fitting_garment.country] + fitting_values(fitting_garment))
        end
      end
    end

    def build_headers
      headers = categories.each_with_object([]) do |category, headers|
        category.category_params.each do |category_param|
          headers << "#{category.name.upcase}, #{category_param.param.title}"
        end
      end

      headers.unshift(*DEFAULT_HEADERS)
    end

    def fitting_values(fitting_garment)
      categories.each_with_object([]) do |category, values|
        category.category_params.each_with_object([]) do |category_param, array|
          measurement = fitting_garment.fitting_garment_measurements.detect { |f_m| f_m.category_param_id == category_param.id }

          values << measurement&.value
        end
      end
    end
  end
end
