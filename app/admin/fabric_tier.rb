ActiveAdmin.register FabricTier do
  decorate_with FabricTierDecorator

  menu false

  config.sort_order = 'id_asc'

  before_filter :right_sidebar!

  filter :title
  filter :order, as: :numeric

  includes fabric_tier_categories: :fabric_category

  permit_params :id, :title, :order, fabric_tier_categories_attributes: [:id, :fabric_category_id, :fabric_tier_id, :_destroy, price: [ :SGD, :GBP ]]

  csv do
    column :id
    column :title
    column :order
    column(:price) { |fabric_tier| fabric_tier.prices_field }
    column :created_at
    column :updated_at
  end

  index download_links: -> { can?(:download_csv, FabricTier) } do
    render 'admin/fabric_tiers/tier_prices'
  end

  show do
    panel 'Fabric Tier Details' do
      attributes_table_for fabric_tier do
        row :id
        row :title
        row :order
        row :created_at
        row :updated_at
      end
      panel 'Fabric Tier Categories' do
        attributes_table_for fabric_tier.fabric_tier_categories.decorate do
          row('Category') do |tier_category|
            span fabric_tier.fabric_category_label(tier_category)
          end
          row(:price) { |tier_category| tier_category.price_field }
        end
      end
    end
  end

  form remote: true do |f|
    render 'admin/fabric_tiers/form'
  end

  member_action :update_tier_category_price, method: :patch

  controller do
    def index
      @fabric_categories = FabricCategory.all
      super
    end

    def new
      @fabric_tier = FabricTier.new
      @fabric_categories_hash = FabricCategory.all.each_with_object({}) { |fabric_category, hash| hash[fabric_category.title] = fabric_category.id }
    end

    def create
      @fabric_tier = FabricTier.create(permitted_params[:fabric_tier])

      render 'admin/fabric_tiers/submit'
    end

    def edit
      @fabric_tier = FabricTier.find(params[:id])
      @fabric_categories_hash = FabricCategory.all.each_with_object({}) { |fabric_category, hash| hash[fabric_category.title] = fabric_category.id }
    end

    def update
      @fabric_tier = FabricTier.find(params[:id])

      @fabric_tier.update(permitted_params[:fabric_tier])

      render 'admin/fabric_tiers/submit'
    end

    def update_tier_category_price
      FabricTiers::UpdateTierCategoryPrice.new(params).call

      head :ok
    end
  end
end
