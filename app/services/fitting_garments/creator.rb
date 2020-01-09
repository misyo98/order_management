module FittingGarments
  class Creator
    def self.create(*attrs)
      new(*attrs).create
    end

    def initialize(params)
      @params = params
      @fitting_garment = FittingGarment.new(params)
    end

    def create
      if fitting_garment.save
        measurements =
          fitting_garment.category.category_params.each_with_object([]) do |c_p, measurements|
            measurements << fitting_garment.fitting_garment_measurements.build(category_param_id: c_p.id)
          end
        FittingGarmentMeasurement.import measurements
      end

      fitting_garment
    end

    private

    attr_reader :fitting_garment
  end
end
