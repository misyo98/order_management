ActiveAdmin.register FabricOption do
  menu false
  config.clear_action_items!

  before_filter :right_sidebar!

  permit_params :id, :fabric_tab_id, :title, :order, :button_type, :placeholder, :outfitter_selection, :tuxedo, :premium,
                :fusible, :manufacturer, :max_characters, :allowed_characters, depends_on_option_value_ids: []

  csv do
    id_column
    column :fabric_tab_id
    column :depends_on_option_value_ids
    column :title
    column :order
    column :button_type
    column :placeholder
    column :outfitter_selection
    column :tuxedo
    column :premium
    column :fusible
    column :manufacturer
  end

  index title: 'Customization Options', download_links: -> { can?(:download_csv, FabricOption) } do
    selectable_column
    id_column
    column('Customization Tab') do |option|
      span link_to option.fabric_tab.title, fabric_tab_path(option.fabric_tab.id) unless option.fabric_tab_id.nil?
    end
    column('Show For Option Values') do |option|
      unless option.depends_on_option_value_ids.blank?
        attributes_table_for option.depends_on_option_value_ids do
          option.depends_on_option_value_ids.each do |id|
            span link_to "ID: #{id}", fabric_option_value_path(id)
          end
        end
      end
    end
    column :title
    column :order
    column(:button_type) { |option| FabricOption::BUTTON_TYPES[option.button_type&.to_sym] }
    column :placeholder
    column(:outfitter_selection) { |option| FabricOption::OUTFITTER_SELECTION[option.outfitter_selection&.to_sym] }
    column(:tuxedo) { |option| FabricOption::TUXEDO_SELECTION[option.tuxedo&.to_sym] }
    column(:premium) { |option| FabricOption::PREMIUM_SELECTION[option.premium&.to_sym] }
    column(:fusible) { |option| FabricOption::FUSIBLE_SELECTION[option.fusible&.to_sym] }
    column(:manufacturer) { |option| FabricOption::MANUFACTURERS[option.manufacturer&.to_sym] }
    actions
  end

  show do
    panel 'Customization Option Details' do
      attributes_table_for fabric_option do
        row :id
        row('Depends On') do
          attributes_table_for dependable do
            if dependable.any?
              dependable.each do |option_value|
                span link_to "ID#{option_value.id} - #{option_value.title}", fabric_option_value_path(option_value.id)
              end
            end
          end
        end
        row('Customization Tab') do |option|
          span link_to option.fabric_tab.title, fabric_tab_path(option.fabric_tab.id) unless option.fabric_tab_id.nil?
        end
        row :title
        row :order
        row(:button_type) { |option| FabricOption::BUTTON_TYPES[option.button_type&.to_sym] }
        row :placeholder
        row(:outfitter_selection) { |option| FabricOption::OUTFITTER_SELECTION[option.outfitter_selection&.to_sym] }
        row(:tuxedo) { |option| FabricOption::TUXEDO_SELECTION[option.tuxedo&.to_sym] }
        row(:premium) { |option| FabricOption::PREMIUM_SELECTION[option.premium&.to_sym] }
        row(:fusible) { |option| FabricOption::FUSIBLE_SELECTION[option.fusible&.to_sym] }
        row(:manufacturer) { |option| FabricOption::MANUFACTURERS[option.manufacturer&.to_sym] }
        row :created_at
      end
    end
  end

  action_item :create, only: :index do
    link_to 'New Customization Option', new_fabric_option_path
  end

  action_item :edit, only: :show do
    link_to 'Edit Customization Option', edit_fabric_option_path
  end

  action_item :alteration, only: :show do
    link_to 'Delete Customization Option', fabric_option_path, method: :delete
  end

  form do |f|
    render 'admin/fabric_options/form'
  end

  collection_action :reorder, method: :patch

  controller do
    def new
      @page_title = 'New Customization Option'
      @fabric_option = FabricOption.new
      @fabric_categories_hash = FabricCategory.all.each_with_object({}) { |fabric_category, hash| hash[fabric_category.title] = fabric_category.id }
      @fabric_tabs_hash = FabricTab.all.each_with_object({}) { |fabric_tab, hash| hash[fabric_tab.title] = fabric_tab.id }
    end

    def create
      @fabric_option = FabricOption.create(permitted_params[:fabric_option])

      redirect_to @fabric_option
    end

    def show
      @fabric_option = FabricOption.find(params[:id])
      formatted_depends_on_ids_array = @fabric_option.depends_on_option_value_ids.map(&:to_i) if @fabric_option.depends_on_option_value_ids
      @dependable = FabricOptionValue.where(id: formatted_depends_on_ids_array)
    end

    def edit
      @fabric_option = FabricOption.find(params[:id])
      @page_title = "Edit #{@fabric_option.title}"
      @fabric_categories_hash = FabricCategory.all.each_with_object({}) { |fabric_category, hash| hash[fabric_category.title] = fabric_category.id }
      @fabric_tabs_hash = FabricTab.all.each_with_object({}) { |fabric_tab, hash| hash[fabric_tab.title] = fabric_tab.id }
      @dependable_array = @fabric_option.fabric_tab.fabric_options.map(&:fabric_option_values).flatten.each_with_object([]) { |value, array| array << ["ID:#{value.id} - #{value.title}", value.id] }
    end

    def update
      @fabric_option = FabricOption.find(params[:id])
      @fabric_option.update(permitted_params[:fabric_option])

      redirect_to @fabric_option
    end

    def reorder
      if params[:fabric_option]
        params[:fabric_option].each_with_index do |id, index|
          FabricTab.find(params[:parent_id]).fabric_options.where(id: id).update_all(order: index + 1)
        end
      end

      head :ok
    end
  end
end
