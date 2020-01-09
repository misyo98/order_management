ActiveAdmin.register FabricTierCategory do
  menu false

  before_filter :right_sidebar!

  permit_params :id, :fabric_category_id, :fabric_tier_id, price: {}

  csv do
    column :id
    column :fabric_category_id
    column :fabric_tier_id
    column :price
    column :created_at
    column :updated_at
  end

  index download_links: -> { can?(:download_csv, FabricTierCategory) } do
    selectable_column
    id_column
    column('Fabric Category') do |tier_category|
      unless tier_category.fabric_category_id.nil?
        span link_to tier_category.fabric_category.title, fabric_category_path(tier_category.fabric_category_id)
      end
    end
    column('Fabric Tier') do |tier_category|
      unless tier_category.fabric_tier_id.nil?
        span link_to tier_category.fabric_tier.title, fabric_tier_path(tier_category.fabric_tier_id)
      end
    end
    column :price
    column :created_at
    column :updated_at
    actions
  end

  show do
    panel 'Fabric Tier Details' do
      attributes_table_for fabric_tier_category do
        row :id
        row('Fabric Category') do |tier_category|
          unless tier_category.fabric_category_id.nil?
            span link_to tier_category.fabric_category.title, fabric_category_path(tier_category.fabric_category_id)
          end
        end
        row('Fabric Tier') do |tier_category|
          unless tier_category.fabric_tier_id.nil?
            span link_to tier_category.fabric_tier.title, fabric_tier_path(tier_category.fabric_tier_id)
          end
        end
        row :price
        row :created_at
        row :updated_at
      end
    end
  end

  form do |f|
    render 'admin/fabric_tier_categories/form'
  end

  controller do
    def new
      @fabric_tier_category = FabricTierCategory.new
    end

    def create
      prices = params[:price_array]
      price_hash = prices.each_with_object({}) { |price, hash| hash[price[:currency]] = price[:value] } if prices

      @fabric_tier_category = FabricTierCategory.create(permitted_params[:fabric_tier_category].merge(price: price_hash))

      redirect_to @fabric_tier_category
    end

    def edit
      @fabric_tier_category = FabricTierCategory.find(params[:id])
    end

    def update
      @fabric_tier_category = FabricTierCategory.find(params[:id])
      prices = params[:price_array]

      if prices
        price_hash = prices.each_with_object({}) { |price, hash| hash[price[:currency]] = price[:value] }
      else
        {}
      end

      @fabric_tier_category.update(permitted_params[:fabric_tier_category].merge(price: price_hash))

      redirect_to @fabric_tier_category
    end
  end
end
