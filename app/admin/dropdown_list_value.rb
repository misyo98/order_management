ActiveAdmin.register_page 'Dropdown List Values' do
  menu false

  content do
    div class: 'sidebar_section panel', id: 'filters_sidebar_section' do
      render "admin/dropdown_list_values/filters"
    end

    paginated_collection(dropdown_list_values.page(params[:page]).per(40), download_links: false) do
      table_for(collection.decorate, sortable: true, class: 'index_table index') do
        column(:id) { |option_value| link_to option_value.id, fabric_option_value_path(option_value.id) }
        column(:order)
        column('Dropdown List') { |option_value| option_value.dropdown_list&.title }
        column :title
        column :manufacturer_code
        column(:price) { |option_value| option_value.price_field }
        column(:manufacturer) { |option_value| FabricOptionValue::MANUFACTURERS[option_value.manufacturer&.to_sym] }
        column(:active) { |option_value| option_value.decorate.active_field }
        column(:tuxedo) { |option_value| FabricOptionValue::TUXEDO_SELECTION[option_value.tuxedo&.to_sym] }
      end
    end
  end

  action_item :download_csv do
    link_to 'Download CSV', download_csv_dropdown_list_values_path
  end

  action_item :import do
    link_to 'Import', import_dropdown_list_values_path
  end

  controller do
    def index
      @q = FabricOptionValue.for_dropdown_list.ransack(params[:q])
      @q.sorts = sorting_order
      @dropdown_list_values = @q.result.order(:order).page(params[:page])
    end

    def download_csv
      dropdown_list_values = FabricOptionValue.for_dropdown_list

      send_data Exporters::Objects::DropdownListValues.new(records: dropdown_list_values).call, filename: "dropdown-list-values-#{Date.today}.csv"
    end

    def import
      render 'admin/dropdown_list_values/import', layout: 'active_admin'
    end

    def do_import
      response = Importers::Objects::DropdownListValues.new(file: params[:file]).call

      if response.success?
        flash[:notice] = I18n.t(:created_item, count: response.count)
      else
        flash[:alert]  = response.error
      end

      redirect_to dropdown_list_values_path
    end

    private

    def sorting_order
      return 'order_date desc' unless params[:order]

      splitted_params = params[:order].split('_')

      sort_order = splitted_params.pop
      sort_column = splitted_params.join('_')

      "#{sort_column} #{sort_order}"
    end
  end
end
