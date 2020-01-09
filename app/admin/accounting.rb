ActiveAdmin.register_page 'Accounting' do
  menu parent: "Accountings", if: -> { can? :index, Accounting }

  content do
    div class: 'sidebar_section panel', id: 'filters_sidebar_section' do
      render "admin/accounting/filters"
    end
    span id: 'reorder-url', 'data-path' => reorder_columns_path, 'data-scope' => params[:scope], 'data-page' => controller_name

    paginated_collection(items, download_links: false) do
      table_for(collection, sortable: true, class: 'index_table index', id: 'index_table_accounting') do
        render 'admin/accounting/index', context: self
      end
    end

    render 'admin/line_item/select_columns_modal', collection: table_columns

  end

  action_item :accountings_csv do
    render 'admin/accounting/download_link'
  end

  action_item :accounting_download_csv do
    link_to 'Download CSV', download_csv_path, class: 'hidden'
  end

  action_item :reorder_columns do
    link_to 'Reorder', 'javascript:;', class: 'reorder-columns', data: { state: :off }
  end

  action_item :shipping_costs_and_duties do
    link_to 'Shipping costs and duties', new_shipping_costs_and_duties_path
  end

  action_item :select_columns, only: :index do
    link_to 'Select Columns', 'javascript:;', id: 'select-columns', data: { toggle: 'modal', target: '#select-columns-modal' }
  end

  controller do

    def index
      @q                = LineItem.joins(:order).ransack(params[:q])
      @q.sorts          = sorting_order
      @sales_persons    = User.with_deleted.pluck(:id, :first_name, :last_name).map { |array| [array[0], "#{array[1]} #{array[2]}"]}
      @sales_locations  = SalesLocation.pluck(:id, :name)
      @tailors          = AlterationTailor.select(:id, :name).all
      @couriers         = CourierCompany.select(:id, :name).all
      @table_columns    = Column.accounting.order(:order).decorate
      @vat_rates        = VatRate.all
      @estimated_cogs   = EstimatedCog.all
      @fx_rates         = FxRate.all
      @reoder_path      = reorder_columns_path
      @items            = @q.result.page(params[:page]).per(20)
      update_order_paid_dates

      respond_to do |format|
        format.html { super }
      end
    end

    def generate_csv
      AccountingGenerateCsv.perform_async(params[:q])

      head :ok
    end

    def download_csv
      send_file(
        "public/#{TempFile.find_by(id: params[:data_id]).attachment_url}",
        filename: "accountings-#{Date.today}.csv",
        type: "application/csv"
      )
    end

    def new_shipping_costs_and_duties
      render 'admin/accounting/new_shipping_costs_and_duties'
    end

    def create_shipping_costs_and_duties
      Accounting::ShippingCosts.new(params).create
      redirect_to accounting_path
    end

    private

    def sorting_order
      return 'created_at desc' unless params[:order]

      splitted_params = params[:order].split('_')

      sort_order = splitted_params.pop
      sort_column = splitted_params.join('_')

      "#{sort_column} #{sort_order}"
    end

    def update_order_paid_dates
      order_ids = @items.pluck('orders.id')
      Orders::UpdatePaidDate.call(order_ids: order_ids)
    end
  end
end
