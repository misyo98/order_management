module MeasurementValidations
  class Creator
    def self.create(*attrs)
      new(*attrs).create
    end

    def initialize(params)
      @measurement_validation = MeasurementValidation.new(params)
    end

    def create
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

    attr_reader :measurement_validation
  end
end
