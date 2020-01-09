ActiveAdmin.register FabricCategory do
  menu false

  before_filter :right_sidebar!

  permit_params :id, :title, :tuxedo, tuxedo_price: [:SGD, :GBP]

  csv do
    id_column
    column :title
    column :tuxedo_price
    column :created_at
    column :updated_at
  end

  index download_links: -> { can?(:download_csv, FabricCategory) } do
    selectable_column
    id_column
    column :title
    column :tuxedo
    column :tuxedo_price
    column :created_at
    column :updated_at
    actions
  end

  show do
    panel 'Fabric Category Details' do
      attributes_table_for fabric_category do
        row :id
        row :title
        row :tuxedo
        row :tuxedo_price
        row :created_at
        row :updated_at
      end
    end
  end

  form do |f|
    render 'admin/fabric_categories/form'
  end

  controller do
    def new
      @fabric_category = FabricCategory.new
    end

    def create
      @fabric_category = FabricCategory.create(permitted_params[:fabric_category])

      redirect_to @fabric_category
    end

    def edit
      @fabric_category = FabricCategory.find(params[:id])
    end

    def update
      @fabric_category = FabricCategory.find(params[:id])

      @fabric_category.update(permitted_params[:fabric_category])

      redirect_to @fabric_category
    end
  end
end
