module MeasurementValidations
  class Updater
    def self.update(*attrs)
      new(*attrs).update
    end

    def initialize(measurement_validation, params)
      @measurement_validation = measurement_validation
      @params = params
    end

    def update
      measurement_validation.assign_attributes(params)

      return measurement_validation unless measurement_validation.valid?

      preprocessor = Preprocessor.preprocess!(measurement_validation)

      if preprocessor.success?
        measurement_validation.save
      else
        preprocessor.errors.each do |error|
          measurement_validation.errors.add(:base, error)
        end
      end

      measurement_validation
    end

    private

    attr_reader :measurement_validation, :params
  end
end
