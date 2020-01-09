module Fits
  module CheckBoxConverter
    extend self

    def convert(params: {})
      params.each { |key, hash| hash[:checked] = hash[:checked] != '0' }
    end
  end
end