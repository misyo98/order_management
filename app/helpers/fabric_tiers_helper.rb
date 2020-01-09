module FabricTiersHelper
  def resolve_tier_category(fabric_tier:, fabric_category:)
    tier_category = fabric_tier.fabric_tier_categories.detect { |t_c| t_c.fabric_category_id == fabric_category.id }

    if tier_category.present?
      tier_category
    else
      fabric_tier.fabric_tier_categories.new(fabric_category_id: fabric_category.id, price: {})
    end
  end
end
