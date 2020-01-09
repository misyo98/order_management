ActiveAdmin.register FabricOptionValue do
  decorate_with FabricOptionValueDecorator

  menu false
  config.clear_action_items!

  before_filter :right_sidebar!

  permit_params :fabric_option_id, :title, :order, :image_url, :tuxedo, :premium, :manufacturer, :manufacturer_code, :active,
                :outfitter_selection, price: {}, depends_on_option_value_ids: []

  csv do
    column :id
    column :fabric_option_id
    column :depends_on_option_value_ids
    column :title
    column :order
    column :image_url
    column(:price) { |option_value| option_value.price_field }
    column(:tuxedo) { |option_value| FabricOptionValue::TUXEDO_SELECTION[option_value.tuxedo&.to_sym] }
    column(:premium) { |option_value| FabricOptionValue::PREMIUM_SELECTION[option_value.premium&.to_sym] }
    column(:manufacturer) { |option_value| FabricOptionValue::MANUFACTURERS[option_value.manufacturer&.to_sym] }
    column(:outfitter_selection) { |option_value| FabricOptionValue::OUTFITTER_SELECTION[option_value.outfitter_selection&.to_sym] }
    column(:active) { |option_value| to_yes_or_no(option_value.active?) }
    column :manufacturer_code
    column :created_at
    column :updated_at
  end

  index :title => 'Customization Option Values', download_links: -> { can?(:download_csv, FabricOptionValue) } do
    selectable_column
    id_column
    column('Customization Option') do |option_value|
      span link_to option_value.fabric_option.title, fabric_option_path(option_value.fabric_option&.id) unless option_value.fabric_option_id.nil?
    end
    column('Show For Option Values') do |option_value|
      unless option_value.depends_on_option_value_ids.blank?
        attributes_table_for option_value.depends_on_option_value_ids do
          option_value.depends_on_option_value_ids.each do |id|
            span link_to "ID: #{id}", fabric_option_value_path(id)
          end
        end
      end
    end
    column :title
    column :order
    column :image_url
    column(:price) { |option_value| option_value.price_field }
    column(:tuxedo) { |option_value| FabricOptionValue::TUXEDO_SELECTION[option_value.tuxedo&.to_sym] }
    column(:premium) { |option_value| FabricOptionValue::PREMIUM_SELECTION[option_value.premium&.to_sym] }
    column(:manufacturer) { |option_value| FabricOptionValue::MANUFACTURERS[option_value.manufacturer&.to_sym] }
    column(:outfitter_selection) { |option_value| FabricOptionValue::OUTFITTER_SELECTION[option_value.outfitter_selection&.to_sym] }
    column(:active) { |option_value| option_value.active_field }
    column :manufacturer_code
    actions
  end

  show do
    panel 'Customization Option Value' do
      attributes_table_for fabric_option_value.decorate do
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
        row('Customization Option') do |option_value|
          span link_to option_value.fabric_option.title, fabric_option_path(option_value.fabric_option.id) unless option_value.fabric_option_id.nil?
        end
        row :title
        row :order
        row :image_url
        row(:price) { |option_value| option_value.price_field }
        row(:tuxedo) { |option_value| FabricOptionValue::TUXEDO_SELECTION[option_value.tuxedo&.to_sym] }
        row(:premium) { |option_value| FabricOptionValue::PREMIUM_SELECTION[option_value.premium&.to_sym] }
        row(:manufacturer) { |option_value| FabricOptionValue::MANUFACTURERS[option_value.manufacturer&.to_sym] }
        row(:outfitter_selection) { |option_value| FabricOptionValue::OUTFITTER_SELECTION[option_value.outfitter_selection&.to_sym] }
        row(:active) { |option_value| to_yes_or_no(option_value.active?) }
        row :manufacturer_code
      end
    end
  end

  action_item :create, only: :index do
    link_to 'New Customization Option Value', new_fabric_option_value_path
  end

  action_item :edit, only: :show do
    link_to 'Edit Customization Option Value', edit_fabric_option_value_path
  end

  action_item :alteration, only: :show do
    link_to 'Delete Customization Option Value', fabric_option_value_path, method: :delete
  end

  form do |f|
    render 'admin/fabric_option_values/form'
  end

  collection_action :reorder, method: :patch

  controller do
    def scoped_collection
      end_of_association_chain.where(dropdown_list_id: nil)
    end

    def new
      @fabric_option_value = FabricOptionValue.new
      @fabric_option_hash = FabricOption.all.each_with_object({}) { |fabric_option, hash| hash[fabric_option.title] = fabric_option.id }
    end

    def create
      @page_title = 'New Customization Option Value'
      prices = params[:price_array]
      price_hash = prices.each_with_object({}) { |price, hash| hash[price[:currency]] = price[:value] } if prices

      @fabric_option_value = FabricOptionValue.create(permitted_params[:fabric_option_value].merge(price: price_hash))

      redirect_to @fabric_option_value
    end

    def show
      @fabric_option_value = FabricOptionValue.find(params[:id])
      formatted_depends_on_ids_array = @fabric_option_value.depends_on_option_value_ids.map(&:to_i) if @fabric_option_value.depends_on_option_value_ids
      @dependable = FabricOptionValue.where(id: formatted_depends_on_ids_array)
    end

    def edit
      @fabric_option_value = FabricOptionValue.find(params[:id])
      @page_title = "Edit #{@fabric_option_value.title}"
      @fabric_option = @fabric_option_value.fabric_option
      @fabric_option_hash = FabricOption.all.each_with_object({}) { |fabric_option, hash| hash[fabric_option.title] = fabric_option.id }
      @dependable_array = @fabric_option_value.fabric_option_id ? @fabric_option_value.fabric_option.fabric_option_values
        .where.not(id: @fabric_option_value.id).pluck(:title, :id) : []
    end

    def update
      @fabric_option_value = FabricOptionValue.find(params[:id])

      if params[:bip_update]
        @fabric_option_value.update(permitted_params[:fabric_option_value])
      else
        prices = params[:price_array]

        if prices
          price_hash = prices.each_with_object({}) { |price, hash| hash[price[:currency]] = price[:value] }
        else
          {}
        end

        @fabric_option_value.update(permitted_params[:fabric_option_value].merge(price: price_hash))
      end

      respond_to do |format|
        format.html { redirect_to @fabric_option_value }
        format.json { head :no_content }
      end
    end

    def reorder
      if params[:fabric_option_value]
        params[:fabric_option_value].each_with_index do |id, index|
          FabricOption.find(params[:parent_id]).fabric_option_values.where(id: id).update_all(order: index + 1)
        end
      end

      head :ok
    end
  end
end
