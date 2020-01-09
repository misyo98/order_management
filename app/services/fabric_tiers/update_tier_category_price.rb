module FabricTiers
  class UpdateTierCategoryPrice
    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(params)
      @params = params
      @fabric_tier = FabricTier.includes(:fabric_tier_categories).find(params[:id])
    end

    def call
      tier_category = resolve_tier_category

      tier_category.save
    end

    private

    attr_reader :params, :fabric_tier

    def resolve_tier_category
      tier_category = fabric_tier.fabric_tier_categories.detect { |t_c| t_c.fabric_category_id == params[:fabric_category_id].to_i }

      if tier_category
        tier_category.price[params[:currency]] = params[:value]

        tier_category
      else
        fabric_tier.fabric_tier_categories.new(
          fabric_category_id: params[:fabric_category_id],
          price: { params[:currency] => params[:value] }
        )
      end
    end
  end
end
