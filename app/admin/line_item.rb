ActiveAdmin.register LineItem do
  actions :all, except: [:destroy, :edit, :new]
  batch_action :destroy, false

  # GEM ACTIVE ADMIN LEFT SIDEBAR
  before_action :set_collapsed_sidebar

  menu priority: 9
  menu label: 'Orders', if: -> { can? :read, LineItem }
  config.per_page = 40

  permit_params :name, :comment_field, :fabric_code, :sales_person, :location_of_sale, :submitter_id, :amount_refunded,
    :fabric_state, :manufacturer_order_number, :sales_person_id, :sales_location_id, :m_order_number, :comment_for_tailor,
    :fabric_code_value, :m_order_status, :fabric_status_value, :state, :alteration_tailor_id, :courier_company_id,
    :tracking_number, :outbound_tracking_number, :fabric_tracking_number, :to_be_shipped, :sent_to_alteration_date, :deduction_sales,
    :deduction_sales_person_id, :deduction_sales_comment, :deduction_ops, :deduction_ops_person_id, :deduction_ops_comment,
    :occasion_date, :delivery_method, :send_reminders, :completion_date, :vat_export, :manufacturer, :ordered_fabric,
    :remind_to_get_measured, meta: [:key, :value, :label]

  # FILTERS
  filter :order_number_matches, label: 'Order number', as: :string
  filter :id_eq, label: 'Item ID', as: :number
  filter :full_name_matches, label: 'Full name', as: :string
  filter :email_matches, label: 'Email', as: :string
  filter :m_order_number_matches, label: 'Manufacturer number', as: :string
  filter :manufacturer, as: :select, collection: { Blank: 0, Old: 1, New: 2 }, label: 'Manufacturer'
  filter :category_in, as: :select, collection: LineItem::CATEGORY_KEYS.keys, label: 'Category'
  filter :status_in, as: :select, collection: LineItem::STATE_QUEUES.map { |state, label| [label, state] }, label: 'Status'
  filter :tracking_number_matches, label: 'Inbound Tracking Number', as: :string
  filter :shipment_received_date_eq, label: 'Shipment Received Date', as: :datepicker
  filter :sales_location_id_eq, as: :select, collection: SalesLocation.pluck(:name, :id), label: 'Sales Location' if SalesLocation.table_exists?
  filter :alteration_tailor_id_eq, as: :select, collection: AlterationTailor.pluck(:name, :id), label: 'Tailor' if AlterationTailor.table_exists?
  filter :delivery_appointment_date, label: 'By Delivery Appointment Date', as: :date_range
  filter :find_in_meta, as: :string
  filter :tag_name_matches, as: :string

  # dynamic scopes
  if LineItemScope.table_exists? && LineItemScope.column_names.all? { |column| column.in? LineItemScope::TABLE_COLUMNS }
    LineItemScope.includes(:user_sales_locations, :item_sales_locations).all.order(:order).each do |scope|
      next unless scope.visible_for_user?(current_user)
      # if you want to know how to do it -
      # https://github.com/activeadmin/activeadmin/blob/c12dc45cdb1922e131044f75bbdcace0213518db/lib/active_admin/scope.rb
      Scope.new(scope.label, nil, show_count: scope.show_counter) do |items|
        if scope.item_sales_location_ids.empty?
          items.with_states(scope.states.reject(&:blank?))
        else
          items.with_states(scope.states.reject(&:blank?)).with_resolved_locations(scope.item_sales_location_ids, scope.include_unassigned_items)
        end
      end
    end
  end

  # not dynamic scope for editing item states
  scope('Change States', nil, if: proc { can?(:edit_state, LineItem) }, show_count: false) do |items|
    items.change_states
  end

  # dynamic csv generator, based on visible columns
  csv do
    column(:id)
    assigns['table_columns'].each do |table_column|
      next unless table_column.visible

      column(table_column.label) { |item| csv_item = LineItemCsvDecorator.decorate(item, context: { timelines: assigns['timelines'] }); csv_item.public_send(table_column.name) }
    end
  end

  # index table itself
  index(title: 'Orders', row_class: -> item { LineItemDecorator.decorate(item, context: { timelines: ApplicationHelper.timelines_collection }).resolve_item_color_class }, download_links: -> { can?(:download_csv, LineItem) && (can?(:edit_state, LineItem) || can?("download_csv_#{params[:scope]}".to_sym, LineItem)) }) do
    within head do
      script src: javascript_path('orders'), type: 'text/javascript'
    end

    span(id: 'reorder-url', 'data-path': reorder_columns_path, 'data-scope': params[:scope], 'data-page': controller_name)
    span(id: 'batch-events-url', 'data-path': batch_events_line_items_path, 'data-page': controller_name)

    render 'admin/line_item/index', context: self

    render 'admin/line_item/select_columns_modal', collection: table_columns
    render 'admin/line_item/error_modal'
    render 'admin/line_item/batch_error_modal'
    render 'admin/line_item/refund_modal'
  end

  show do
    attributes_table do
      row :id
      row :order
      row :state
      row :subtotal
      row :total_tax
      row :total
      row :price
      row :quantity
      row :tax_class
      row :name
      row :product
      row :sku
      row :reference
      row :deleted_at
      row :created_at
      row :updated_at
    end

    if can? :update_meta, LineItem
      render 'admin/line_item/meta_fields', line_item: line_item
    elsif can? :read_meta, LineItem
      render 'admin/line_item/meta_field_list', line_item: line_item
    end
  end

  # ACTION ITEMS IS A BUTTON UP ABOVE IN THE RIGHT CORNER
  action_item :shipment_numbers, only: :index, if: proc { can? :shipment_numbers, LineItem } do
    link_to 'Enter Shipment Receipt', shipment_number_line_items_path
  end

  action_item :reorder_columns, only: :index, if: proc { can? :manage_columns, Column }  do
    link_to 'Reorder', 'javascript:;', class: 'reorder-columns', data: { state: :off }
  end

  action_item :select_columns, only: :index, if: proc { can? :manage_columns, Column } do
    link_to 'Select Columns', 'javascript:;', id: 'select-columns', data: { toggle: 'modal', target: '#select-columns-modal' }
  end

  action_item :import_link, if: proc { can? :import_link, LineItem } do
    link_to 'Import tracking numbers', tracking_numbers_line_items_path, class: 'btn btn-primary'
  end

  action_item :repars_order, if: proc { can? :manage_columns, Column } do
    link_to 'Reparse Existing Order', reparse_order_line_items_path, class: 'btn btn-primary'
  end

  action_item :import_states_link, if: proc { can? :import_states, LineItem } do
    link_to 'Import Orders', import_states_line_items_path, class: 'btn btn-primary'
  end

  # BATCH ACTIONS
  # batch_action :destroy, if: proc { can?(:edit_state, LineItem) } do |ids|
  #   LineItem.where(id: ids).delete_all
  #
  #   flash[:notice] = 'Successfully deleted'
  #   redirect_to :back
  # end

  batch_action :remove, if: proc { can?(:edit_state, LineItem) } do |ids|
    LineItem.where(id: ids).each { |i| i.delete_item }

    flash[:notice] = 'Successfully removed'
    redirect_to :back
  end

  batch_action :set_location_of_sale_for, if: proc { !current_user.tailor? },  form: -> { { location: SalesLocation.pluck(:name, :id) } } do |ids, inputs|
    items = LineItem.where(id: ids)

    if items.update_all(sales_location_id: inputs[:location])
      flash[:notice] = I18n.t(:updated_item, count: items.count)
    end

    redirect_to :back
  end

  batch_action :set_sales_person_for, if: proc { can?(:edit_sales_person, LineItem) }, form: -> { { person: User.pluck(:first_name, :last_name, :id).map { |us_arr| ["#{us_arr[0]} #{us_arr[1]}", us_arr[2]] } } } do |ids, inputs|
    items = LineItem.where(id: ids)

    if items.update_all(sales_person_id: inputs[:person])
      flash[:notice] = I18n.t(:updated_item, count: items.count)
    end

    redirect_to :back
  end

  batch_action :set_courier_company_for, if: proc { !current_user.tailor? }, form: -> { { courier_company: CourierCompany.pluck(:name, :id) } } do |ids, inputs|
    items = LineItem.where(id: ids)

    if items.update_all(courier_company_id: inputs[:courier_company])
      flash[:notice] = I18n.t(:updated_item, count: items.count)
    end

    redirect_to :back
  end

  batch_action :set_alteration_tailor_for, form: -> { { alteration_tailor: AlterationTailor.pluck(:name, :id) } } do |ids, inputs|
    items = LineItem.where(id: ids)

    if items.update_all(alteration_tailor_id: inputs[:alteration_tailor])
      flash[:notice] = I18n.t(:updated_item, count: items.count)
    end

    redirect_to :back
  end

  # ROUTES DEFINITIONS
  collection_action :tracking_numbers,              method: :get
  collection_action :import_states,                 method: :get
  collection_action :shipment_number,               method: :get
  collection_action :tracking_numbers_example_csv,  method: :get
  collection_action :batch_events,                  method: :get
  collection_action :batch_trigger_state,           method: :patch
  collection_action :undo_batch_state,              method: :patch
  collection_action :batch_update,                  method: :patch
  collection_action :reparse_order,                 method: :get
  collection_action :reparse_order_items,           method: :patch

  member_action     :trigger_state,                 method: :patch
  member_action     :refresh_state,                 method: :get
  member_action     :update_state,                  method: :patch
  member_action     :update_meta,                   method: [:patch, :put]
  member_action     :trigger_fabric_state,          method: [:patch, :put]
  member_action     :mark_as_copied,                method: [:patch, :put]
  member_action     :create_remake,                 method: :get
  member_action     :new_refund,                    method: :get
  member_action     :update_refund,                 method: :patch
  member_action     :no_profile_message,            method: :get
  member_action     :resend_delivery_email,         method: :get
  member_action     :new_meta,                      method: :get
  member_action     :create_meta,                   method: :post
  member_action     :destroy_meta,                  method: :delete
  member_action     :tags,                          method: :patch

  # CONTROLLER
  controller do
    before_action :reload_scopes, only: :index
    before_action :set_paper_trail_whodunnit, :info_for_paper_trail, only: :update_meta
    before_action :resolve_default_scope, only: :index
    before_action :resolve_tailor_scope, only: :index, if: proc { current_user.tailor? }

    def reload_scopes
      resource = active_admin_config
      resource.scopes.delete_if { |persisted_scope| !persisted_scope.name.in?(LineItem::STATIC_SCOPE_NAMES) }

      LineItemScope.includes(:user_sales_locations, :item_sales_locations).all.order(:order).each do |scope|
        next unless scope.visible_for_user?(current_user)

        new_scope = ActiveAdmin::Scope.new(scope.label, nil, show_count: scope.show_counter) do |item|
                      if scope.custom_scope.present?
                        item.send(scope.custom_scope)
                      elsif scope.item_sales_location_ids.empty?
                        item.with_states(scope.states.reject(&:blank?))
                      else
                        item.with_states(scope.states.reject(&:blank?)).with_resolved_locations(scope.item_sales_location_ids, scope.include_unassigned_items)
                      end
                    end

        resource.scopes << new_scope
      end
    end

    def scoped_collection
      # commmented out approach for custom filters
      # @q = LineItem.with_index_includes(country: current_user.country).search(params[:q])
      # @q.result
      if params[:scope] && LineItemScope.find_by(custom_scope: params[:scope])
        super
      else
        super.with_index_includes
           .by_location_or_country(sales_location_ids: current_user.sales_location_ids, country: current_user.country)
      end
    end

    def index
      @sales_persons     = ApplicationHelper.sales_persons_collection.insert(0, [nil, ''])
      @sales_locations   = ApplicationHelper.sales_locations_collection
      @tailors           = ApplicationHelper.tailors_collection
      @couriers          = ApplicationHelper.couriers_collection
      @timelines         = ApplicationHelper.timelines_collection
      @ops_people        = ApplicationHelper.ops_collection.insert(0, [nil, ''])
      @reoder_path       = reorder_columns_path
      @table_columns     =
        if params[:scope] && !params[:scope].in?(LineItem::STATIC_SCOPES)
          LineItemScope.find_by(label: params[:scope].titleize).columns.order(:order).decorate
        else
          Column.line_items.order(:order).decorate
        end

      super
    end

    def update
      params.deep_merge!(line_item: { submitter_id: current_user.id })

      # Prevent State error on update Fabric Code
      # TODO: Remove this code if you find the reason
      @item = LineItem.unscoped.find(params[:id])
      @item.update(permitted_params[:line_item])

      respond_to do |format|
        format.html { super }
        format.js   { super }
        format.json { head :no_content }
      end
    end

    def batch_update
      crud     = LineItems::CRUD.new(params: params)
      response = crud.batch_update

      head :no_content
    end

    def tags
      @line_item = LineItem.find(params[:id])

      LineItems::UpdateTags.(@line_item, params[:tags])

      render 'admin/line_item/tags'
    end

    def new_meta
      @line_item = LineItem.find(params[:id])

      render 'admin/line_item/new_meta'
    end

    def create_meta
      @line_item = LineItem.find(params[:id])
      @result = LineItems::CreateMeta.(@line_item, params)

      render 'admin/line_item/create_meta'
    end

    def update_meta
      fabric_code = params[:line_item][:meta].detect{ |h| h['key'] == 'Fabric Code'}
      params[:line_item][:fabric_code_value] = fabric_code['value'] if fabric_code
      @line_item = LineItem.find_by!(id: params[:id])
      @line_item.update(permitted_params[:line_item])

      render 'admin/line_item/update_meta'
    end

    def destroy_meta
      @line_item = LineItem.find(params[:id])
      @line_item = LineItems::DestroyMeta.(@line_item, params)

      render 'admin/line_item/destroy_meta'
    end

    def tracking_numbers
      render 'admin/line_item/tracking_numbers'
    end

    def shipment_number
      render 'admin/line_item/shipment_number'
    end

    def import_states
      render 'admin/line_item/import_states'
    end

    def import_csv
      response = Importers::Objects::Orders.new(file: params[:file], user_id: current_user.id).call
      if response.success?
        flash[:notice]  = I18n.t(:updated_item, count: response.count)
      else
        flash[:alert]   = response.error
      end
      redirect_to line_items_path
    end

    def update_shipments
      crud            = LineItems::CRUD.new(params: params.merge!(user_id: current_user.id))
      response        = crud.update_shipments
      flash[:notice]  = I18n.t(:updated_item, count: response[:item_count])

      redirect_to line_items_path
    end

    def import_tracking_numbers
      response          = Importers::Objects::TrackingNumbers.new(file: params[:file], user_id: current_user.id).call
      if response.success?
        flash[:notice]  = I18n.t(:imported_numbers, count: response.count, message: response.message)
      else
        flash[:alert]   = response.error
      end
      redirect_to line_items_path
    end

    def trigger_state
      result       = LineItems::TriggerState.(params.merge!(user_id: current_user.id))
      @item        = result.item.decorate
      @order_items = result.items_for_mass_update
      @order_items = @order_items.includes(order: [customer: [profile: :categories]]).decorate if @order_items.any?

      render 'admin/line_item/trigger_state'
    end

    def refresh_state
      item  = LineItem.find_by(id: params[:id])
      @item = item.decorate

      render 'admin/line_item/update_state'
    end

    def update_state
      crud = LineItems::CRUD.new(params: params.merge!(user_id: current_user.id))
      crud.update_state

      head :no_content
    end

    def trigger_fabric_state
      crud = LineItems::CRUD.new(params: params.merge!(user_id: current_user.id))
      crud.trigger_fabric_state

      head :no_content
    end

    def create_remake
      crud = LineItems::CRUD.new(params: params.merge!(user_id: current_user.id))
      crud.create_remake

      flash[:alert] = crud.errors.join('; ') if crud.errors.any?

      redirect_to :back
    end

    def new_refund
      @item = LineItem.find_by(id: params[:id])

      render 'admin/line_item/new_refund'
    end

    def update_refund
      crud            = LineItems::CRUD.new(params: params)
      response_object = crud.update_refund
      @item           = response_object.decorate

      if @item.errors.any?
        render 'admin/line_item/new_refund'
      else
        render 'admin/line_item/update_state'
      end
    end

    def batch_events
      items   = LineItem.where(id: params[:ids])
      events  = LineItems::AvailableStates.find_similar_states(items: items, user: current_user)
      @response_hash = { events: events[:default], extra_events: events[:extra], item_ids: params[:ids] }

      render 'admin/line_item/batch_events'
    end

    def batch_trigger_state
      command = LineItems::BatchStateTrigger.new(params.merge!(user_id: current_user.id))
      @response_object = command.call

      render 'admin/line_item/batch_trigger_state'
    end

    def undo_batch_state
      command = LineItems::UndoBatchState.new(params)
      @response_object = command.call

      render 'admin/line_item/undo_batch_state'
    end

    def tracking_numbers_example_csv
      url = File.join(Rails.root, 'public', 'inbound_tracking_numbers_example.csv')
      send_file(url, type: 'application/csv')
    end

    def no_profile_message
      render 'admin/line_item/no_profile_error'
    end

    def resend_delivery_email
      @item = LineItem.find_by(id: params[:id])

      EmailsQueues::CreateDeliveryEmail.(@item)
      @item.submitter_id = current_user.id
      @item.log_resend_delivery_email

      render 'admin/line_item/resend_delivery_email'
    end

    def reparse_order
      render 'admin/line_item/reparse_order'
    end

    def reparse_order_items
      if Order.exists?(params[:order_id])
        Woocommerce::Hub.create_single_order(params[:order_id])
        flash[:notice] = 'Order has been successfully reparsed!'

        redirect_to line_items_path
      else
        flash[:alert] = 'Order is not in the system yet!'

        redirect_to :back
      end
    end

    def mark_as_copied
      @item = LineItem.find_by(id: params[:id])
      @item.copied!

      render 'admin/line_item/mark_as_copied'
    end

    private

    def set_collapsed_sidebar
      @sidebar_options[:is_collapsed] = true
    end

    def info_for_paper_trail
      { meta_fields_changed: true }
    end

    def resolve_default_scope
      if current_user.suit_placing? && params[:scope].blank?
        params[:scope] = 'orders_to_create'
      end
    end

    def resolve_tailor_scope
      if current_user.tailor? && !params[:scope].in?(User::SCOPES_FOR_TAILORS)
        params[:scope] = 'alteration_requests'
      end
    end
  end
end
