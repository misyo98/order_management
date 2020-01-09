module Customers
  module Builder
    extend self

    def build_fits(object:)
      fit_ids = object.fits.pluck(:category_id)
      categories = Category.all.order(:order).select(:id, :visible)
      categories.each { |category| object.fits.build(category: category, checked: !category.visible) unless category.id.in?(fit_ids)}
    end
  end
end
