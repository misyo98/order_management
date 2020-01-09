ActiveAdmin.register_page 'Remaining COGS' do
  menu parent: "Accountings", if: -> { can? :index, RealCog }

  content do
    div class: 'sidebar_section panel', id: 'filters_sidebar_section' do
      render "admin/remaining_cogs/filters"
    end
    span id: 'reorder-url', 'data-path' => reorder_columns_path, 'data-scope' => params[:scope], 'data-page' => controller_name
    render 'admin/remaining_cogs/custom_batch'
    
    div class: 'panel_contents' do
      paginated_collection(cogs, download_links: false) do
        table_for(collection, sortable: true, class: 'index_table index', id: 'index_table_remaining_cogs') do
          render 'admin/remaining_cogs/index', context: self
        end
      end
    end

    render 'admin/line_item/select_columns_modal', collection: table_columns
    
    render 'admin/remaining_cogs/batch_bucket_modal'
  end

  action_item :reorder_columns do
    link_to 'Reorder', 'javascript:;', class: 'reorder-columns', data: { state: :off }
  end

  action_item :select_columns, only: :index do
    link_to 'Select Columns', 'javascript:;', id: 'select-columns', data: { toggle: 'modal', target: '#select-columns-modal' }
  end

  controller do
    def index
      @q                        = RealCog.all.ransack(params[:q])
      @q.sorts = sorting_order
      @table_columns            = Column.remaining_cogs.order(:order).decorate
      @reoder_path              = reorder_columns_path
      @cogs                     = @q.result.page(params[:page]).per(40)
      @cost_buckets             = ApplicationHelper.cost_buckets_collection
      cogs_manufacturer_ids     = @cogs.pluck(:manufacturer_id)
      @matched_items            = LineItem.where(m_order_number: cogs_manufacturer_ids).pluck(:m_order_number, :id)
    end

    def batch_edit_buckets
      @buckets = CostBucket.pluck(:label, :id)

      render 'admin/remaining_cogs/batch_edit_buckets'
    end

    def batch_update_buckets
      if RealCog.where(id: params[:cog_ids]).update_all(cost_bucket_id: params[:cost_bucket_id])
        flash[:notice] = 'COGS were successfully updated'
      end
      render 'admin/remaining_cogs/batch_update_buckets'
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