module Customers
  class CategoryStatusesPreparer
    N_A_STATUS = 'N/A'.freeze

    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(customer)
      @profile_categories = customer.profile&.categories&.visible || []
      @categories = Category.all.visible
    end

    def call
      categories.each_with_object({}) do |category, prepared_categories|
        profile_category = profile_categories.find { |profile_category| profile_category.category_id == category.id }

        if profile_category
          prepared_categories[profile_category.category_name] = profile_category.status.humanize
        else
          prepared_categories[category.name] = N_A_STATUS
        end
      end
    end

    private

    attr_reader :profile_categories, :categories
  end
end
