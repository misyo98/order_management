ActiveAdmin.register EnabledFabricCategory do
  menu false
  config.clear_action_items!
  config.batch_actions = false

  before_filter :right_sidebar!

  permit_params :id, :fabric_info_id, :fabric_category_id

  csv do
    id_column
    column :fabric_info_id
    column :fabric_category_id
    column :created_at
    column :updated_at
  end

  index download_links: -> { can?(:download_csv, EnabledFabricCategory) } do
    selectable_column
    id_column
    column :fabric_info_id
    column :fabric_category_id
  end

  show do
    panel 'Enabled Fabric Category Details' do
      attributes_table_for enabled_fabric_category do
        row :id
        row('Fabric Info') do |enabled_cat|
          span link_to enabled_cat.fabric_info.fabric_code, fabric_info_path(enabled_cat.fabric_info.id) unless enabled_cat.fabric_info_id.nil?
        end
        row('Category') do |enabled_cat|
          span link_to enabled_cat.fabric_category.title, fabric_category_path(enabled_cat.fabric_category.id) unless enabled_cat.fabric_category_id.nil?
        end
        row :created_at
        row :updated_at
      end
    end
  end

  form do |f|
    render 'admin/enabled_fabric_categories/form'
  end

  controller do
    def new
      @enabled_fabric_category = EnabledFabricCategory.new
      @fabric_category_hash = FabricCategory.all.each_with_object({}) { |fabric_category, hash| hash[fabric_category.title] = fabric_category.id }
    end

    def create
      @enabled_fabric_category = EnabledFabricCategory.create(permitted_params[:enabled_fabric_category])

      redirect_to @enabled_fabric_category
    end

    def edit
      @enabled_fabric_category = EnabledFabricCategory.find(params[:id])
      @fabric_category_hash = FabricCategory.all.each_with_object({}) { |fabric_category, hash| hash[fabric_category.title] = fabric_category.id }
    end

    def update
      @enabled_fabric_category = EnabledFabricCategory.find(params[:id])

      @enabled_fabric_category.update(permitted_params[:enabled_fabric_category])

      redirect_to @enabled_fabric_category
    end
  end
end
