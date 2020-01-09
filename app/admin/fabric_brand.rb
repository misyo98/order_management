ActiveAdmin.register FabricBrand do
  menu false
  config.clear_action_items!
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'order_asc'

  before_filter :right_sidebar!

  filter :title

  permit_params :id, :title, :order

  csv do
    id_column
    column :title
    column :order
    column :created_at
    column :updated_at
  end

  index download_links: -> { can?(:download_csv, FabricBrand) } do
    column do
      span class: 'fas fa-arrows-alt'
    end
    id_column
    column :title
    column :order
    column :created_at
    column :updated_at

    render partial: 'shared/submit_order', locals: { table_name: 'fabric_brands' }
  end

  show do
    panel 'Fabric Brand Details' do
      attributes_table_for fabric_brand do
        row :id
        row :title
        row :created_at
        row :updated_at
        row('Archived') { |brand| FabricBookDecorator.decorate(brand).archived_field }
      end
    end

    panel 'Fabric Books' do
      render partial: 'fabric_brands/brand_books'
    end
  end

  form do |f|
    inputs 'Details' do
      input :title
    end
    actions
  end

  collection_action :archived
  collection_action :reorder, method: :patch

  action_item :archived_brands, only: :index do
    link_to 'Archived Brands', archived_fabric_brands_path
  end

  controller do
    def show
      @fabric_brand = FabricBrand.with_deleted.find(params[:id])
      @fabric_books = FabricInfo.where(fabric_brand_id: @fabric_brand.id).map(&:fabric_book).uniq
      super
    end

    def archived
      @deleted_fabric_brands = FabricBrand.only_deleted.page(params[:page])
    end

    def reorder
      SetOrder.(items: params[:fabric_brand], table_name: :fabric_brand) if params[:fabric_brand]

      @ordered_brands = FabricBrand.pluck(:id, :order)
    end
  end
end
