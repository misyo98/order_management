ActiveAdmin.register FabricInfo do
  menu false

  decorate_with FabricInfoDecorator

  config.clear_action_items!
  config.batch_actions = false
  config.sort_order = "order_asc"

  before_filter :right_sidebar!

  filter :fabric_code
  filter :manufacturer_fabric_code, filters: [:equals, :contains]

  includes :enabled_fabric_categories, :fabric_book, :fabric_brand, :fabric_manager

  permit_params :fabric_brand_id, :fabric_book_id, :fabric_code, :manufacturer_fabric_code, :fabric_composition, :fabric_tier_id,
                :fabric_type, :usd_for_meter, :fabric_addition, :valid_from, :manufacturer, :fusible, :premium, :season, :active,
                :category_shirts, :category_pants, :category_jackets, :category_waistcoats, :category_overcoats, :category_chinos

  index row_class: -> record { record.oos_or_discontinued_warning_label }, download_links: [:xml, :json], if: -> { can?(:download_csv, FabricInfo) } do
    render 'admin/fabric_infos/import_result'
    selectable_column
    unless current_user.limited_fabrics_access?
      id_column
      column :order
    end
    column(:fabric_brand_id) { |info| info.fabric_brand_field }
    column(:fabric_book_id) { |info| info.fabric_book_field }
    column :fabric_code
    column :manufacturer_fabric_code
    column :fabric_composition
    column(:fabric_tier_id) { |info| info.fabric_tier_field }
    column(:fabric_type) { |info| info.fabric_type&.dasherize&.humanize }
    column(:manufacturer) { |info| FabricInfo::MANUFACTURERS[info.manufacturer.to_sym] if info.manufacturer }
    column :active
    column('OOS/Discontinued') { |info| info.oos_or_discontinued_field }
    unless current_user.limited_fabrics_access?
      column :fusible unless current_user.outfitter?
      column :premium unless current_user.outfitter?
      column :season unless current_user.outfitter?
      column('USD / m') { |info| info.usd_for_meter }
      column('Fabric addition (USD) / meter (on top of manufacturing costs)') { |info| info.fabric_addition }
      column :valid_from
      column('Shirts') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Shirts'] }.present?) }
      column('Trousers') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Trousers'] }.present?) }
      column('Jackets') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Jackets'] }.present?) }
      column('Waistcoats') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Waistcoats'] }.present?) }
      column('Overcoats') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Overcoats'] }.present?) }
      column('Chinos') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Chinos'] }.present?) }
      column('TrenchCoats') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['TrenchCoats'] }.present?) }
    end
    # actions
  end

  show do
    attributes_table do
      row :id
      row :order
      row :fabric_brand_id do |info|
        span link_to info.fabric_brand_id, fabric_brand_path(id: info.fabric_brand_id) unless info.fabric_brand_id.nil?
      end
      row :fabric_book_id do |info|
        span link_to info.fabric_book_id, fabric_book_path(id: info.fabric_book_id) unless info.fabric_book_id.nil?
      end
      row :fabric_code
      row :manufacturer_fabric_code
      row :fabric_composition
      row :fabric_tier_id do |info|
        span link_to info.fabric_tier_id, fabric_tier_path(id: info.fabric_tier_id) unless info.fabric_tier_id.nil?
      end
      row(:fabric_type) { |info| info.fabric_type&.dasherize&.humanize }
      row(:manufacturer) { |info| FabricInfo::MANUFACTURERS[info.manufacturer.to_sym] if info.manufacturer }
      row :fusible
      row :premium
      row :season
      row :active
      row('USD / m') { |info| info.usd_for_meter }
      row('Fabric addition (USD) / meter (on top of manufacturing costs)') { |info| info.fabric_addition }
      row :valid_from
      row('Shirts') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Shirts'] }.present?) }
      row('Trousers') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Trousers'] }.present?) }
      row('Jackets') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Jackets'] }.present?) }
      row('Waistcoats') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Waistcoats'] }.present?) }
      row('Overcoats') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Overcoats'] }.present?) }
      row('Chinos') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['Chinos'] }.present?) }
      row('TrenchCoats') { |info| to_yes_or_no(info.enabled_fabric_categories.detect { |e_c| e_c.fabric_category_id == categories['TrenchCoats'] }.present?) }
      row('Archived') { |info| info.deleted? ? "Archived: #{info.deleted_at}" : 'No' }
    end
  end

  # form do |f|
  #   inputs 'Details' do
  #     input :fabric_brand_id, as: :select, collection: FabricBrand.all
  #     input :fabric_book_id, as: :select, collection: FabricBook.all
  #     input :fabric_code
  #     input :manufacturer_fabric_code
  #     input :fabric_tier_id, as: :select, collection: FabricTier.all
  #     input :fabric_type
  #     input :manufacturer, as: :select, collection: FabricInfo::MANUFACTURERS.map { |key, value| [value, key] }, include_blank: false
  #     input :fusible
  #     input :premium
  #     input :season
  #     input :active
  #     input :usd_for_meter
  #     input :fabric_addition
  #     input :valid_from, as: :datepicker
  #   end
  #   actions
  # end

  collection_action :get_fabric_infos, method: :get
  collection_action :generate_csv
  collection_action :download_csv, method: :get
  collection_action :archived
  member_action     :fabric_tier_prices, method: :get

  action_item :fabric_infos_csv, only: :index, if: proc { can? :fabrics_csv, FabricInfo } do
    render 'admin/fabric_infos/download_link'
  end

  action_item :fabric_infos_download_csv, only: :index, if: proc { can? :fabrics_csv, FabricInfo } do
    link_to 'Download CSV', download_csv_path, class: 'hidden'
  end

  action_item :archived_infos, only: :index, if: proc { can? :archived, FabricInfo } do
    link_to 'Archived Fabric Infos', archived_fabric_infos_path
  end

  active_admin_import

  controller do
    respond_to :html, :json

    def index
      @categories = FabricCategory.all.each_with_object({}) { |category, hash| hash[category.title] = category.id }
      super
    end

    def show
      authorize! :crud, FabricInfo

      @fabric_info = FabricInfo.with_deleted.includes(:enabled_fabric_categories).find(params[:id])
      @categories = FabricCategory.all.each_with_object({}) { |category, hash| hash[category.title] = category.id }
      super
    end

    def get_fabric_infos
      @fabric_infos = FabricInfo.ransack(params[:q]).result

      render 'admin/fabric_infos/get_fabric_infos'
    end

    def archived
      authorize! :archived, FabricInfo

      @deleted_fabric_infos = FabricInfo.only_deleted.includes(:fabric_book, :fabric_brand).page(params[:page])
    end

    def do_import
      if params[:active_admin_import_model]
        ImportFabricInfos.perform_async(Base64.strict_encode64(File.read params[:active_admin_import_model][:file].path))

        redirect_to fabric_infos_path, notice: 'Fabric Infos are being imported in the background!'
      else
        redirect_to :back, alert: 'Please attach a CSV file.'
      end
    end

    def generate_csv
      FabricInfosGenerateCsv.perform_async

      head :ok
    end

    def download_csv
      send_file(
        "public/#{TempFile.find_by(id: params[:data_id]).attachment_url}",
        filename: "fabric-infos-#{Date.today}.csv",
        type: "application/csv"
      )
    end

    def fabric_tier_prices
      fabric_info = FabricInfo.find(params[:id])
      @fabric_tier = fabric_info.fabric_tier
      @fabric_tier_prices = @fabric_tier.fabric_tier_categories
    end
  end
end
