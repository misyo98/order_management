module ProfileHelper
  BIG_HEADERS = ['Measurement Check'].freeze
  MEDIUM_HEADERS = [].freeze
  SMALL_HEADERS = ['Measurement', 'Category', 'Fitting Garment'].freeze
  MEASUREMENT_HEADERS = ['Allowances', 'Adjustment', 'Final Garment', 'Changes +/-'].freeze
  FITTING_GARMENT_HEADERS = ['Fitting Garment', 'Changes +/-'].freeze

  def table_classes(header:, with_fitting_garment: false)
    classes = [header.parameterize.underscore]
    classes << 'col-category' if header.in?(BIG_HEADERS)
    classes << 'col-category-md' if header.in?(MEDIUM_HEADERS)
    classes << 'col-category-sm' if header.in?(SMALL_HEADERS)
    if header.in?(FITTING_GARMENT_HEADERS) && !with_fitting_garment
      classes << 'hidden'
    end
    classes
  end
end
