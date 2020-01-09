ActiveAdmin.register AlterationSummary do
  decorate_with AlterationSummaryDecorator

  menu parent: "Alterations", label: 'All Alteration', if: -> { can?(:read, AlterationSummary) }
  actions :all, except: [:destroy, :edit, :new]
  config.per_page = [30, 50, 75, 100]

  permit_params alteration_service_ids: [],
    alteration_services_attributes: [
      :category_id, :name, :order, :custom, :author_id,
      alteration_service_tailors_attributes: [:id, :alteration_tailor_id, :price]
    ]
  before_action :right_sidebar!

  filter :customer_name_match, label: 'Customer name', as: :string
  filter :due_date, as: :date_range
  filter :by_alteration_tailor_name, label: 'Alteration Tailor', as: :select2_multiple, input_html: { class: 'selectpicker' }, collection: AlterationTailor.pluck(:name, :name), unless: proc { current_user.tailor? }
  filter :alteration_send, label: "Date sent to alteration tailor", as: :date_range
  filter :alteration_back, label: "Date back from alteration tailor", as: :date_range
  filter :urgent
  filter :manufacturer_number_match, label: 'Manufacturer Number', as: :string
  filter :created_by_match, label: 'Created by', as: :string

  scope :to_be_altered, default: proc { current_user.tailor? }, show_count: false

  scope :to_be_updated, show_count: false

  scope :to_be_invoiced, show_count: false

  scope :invoiced, show_count: false

  scope :paid, show_count: false

  scope('All', :all, default: true, show_count: false)

  csv do
    if current_user.tailor?
      column('Manufacturer order number') { |summary| summary.manufacturer_code }
      column('Category') { |summary| summary.altered_categories_field }
      column(:first_name) { |summary| summary.customer_first_name }
      column(:last_name) { |summary| summary.customer_last_name }
      column(:received_date) { |summary| summary.alteration_send_date }
      column(:back_date) { |summary| summary.alteration_back_date }
      column(:alteration_services) { |summary| summary.alteration_services.pluck(:name).join(', ') }
      column('Location of Sale') { |summary| summary.locations_of_sales }
      column('Due date') { |summary| summary.due_date }
      column(:urgent) { |summary| summary.maybe_urgent_text }
      column(:payment_required) { |summary| summary.maybe_payment_required_text }
      column(:amount) { |summary| summary.amount }
      column(:currency) { |summary| summary.alteration_tailors&.first&.decorate&.formatted_currency }
    else
      column :id
      column(:customer) { |summary| summary.customer_name }
      column(:type) { |summary| summary.resolve_action_status_name }
      column(:urgent) { |summary| summary.maybe_urgent_text }
      column(:payment_required) { |summary| summary.maybe_payment_required_text }
      column :due_date
      column(:summary_order)
      column('Alteration tailor') { |summary| summary.get_alteration_talors }
      column('Date send to alteration tailor') { |summary| summary.alteration_send_date }
      column('Back From Alteration Tailor') { |summary| summary.alteration_back_date }
      column(:altered_categories) { |summary| summary.altered_categories_field }
      column(:alteration_services) { |summary| summary.alteration_services.pluck(:name).join(', ') }
      column(:manufacturer_number) { |summary| summary.manufacturer_code }
      column(:amount) { |summary| summary.amount }
      column(:currency) { |summary| summary.alteration_tailors&.first&.decorate&.formatted_currency }
      column('Location of Sale') { |summary| summary.locations_of_sales }
      column :created_at
      column :created_by
      column :sales_person
      column :updated_at
    end
  end

  index(title: 'Alterations', download_links: -> { can?(:download_csv, AlterationSummary) }) do
    within head do
      script src: javascript_path('orders'), type: 'text/javascript'
    end

    render 'admin/line_item/error_modal'
    render 'admin/line_item/refund_modal'

    if invoice.present?
      div class: 'text-center alert alert-warning' do
        span "YOU ARE CURRENTLY EDITING INVOICE ##{invoice.id}"
        span(link_to('Finish', invoices_path, class: 'btn btn-default'), class: 'block')
      end
    end
    if params[:scope] == 'to_be_invoiced' || (invoice.present? && params[:scope] == 'invoiced')
      column '' do |summary|
        render 'check_box', summary: summary, invoice: invoice
      end
    end
    if current_user.tailor?
      if params[:scope] == 'to_be_invoiced'
        span do
          check_box_tag 'select_all', false, false, id: 'select_all_summaries_for_invoice'
        end
      end
      column 'Manufacturer order number', :manufacturer_number do |summary|
        summary.manufacturer_code
      end
      column(:state) { |summary| AlterationSummary::STATE_QUEUES[summary.state.to_sym] } if params[:scope] == 'all'
      column 'Category', :category do |summary|
        summary.altered_categories_field
      end
      column(:first_name) { |summary| summary.customer_first_name }
      column(:last_name) { |summary| summary.customer_last_name }
      column(:received_date) { |summary| summary.alteration_send_date }
      column(:back_date, sortable: 'line_items.sent_to_alteration_date') { |summary| summary.alteration_back_date }
      column('Location of Sale') { |summary| summary.locations_of_sales }
      column('Due date', sortable: :requested_completion) do |summary|
        summary.due_date_cell
      end
      column('Comment for tailor') { |summary| summary.items.map(&:comment_for_tailor).join('; ') }
      column(:urgent) { |summary| summary.urgent_field }
      column(:payment_required) { |summary| summary.payment_required_field }
      column('Amount') { |summary| summary.maybe_amount_link }
      column :invoice_number
      column :invoice_status
      actions defaults: false do |summary|
        item 'Open Sheet', summary.pdf_path, class: 'btn btn-primary view_link member_link'
        item summary.add_service_link_title, services_alteration_summary_path(id: summary.id), class: 'btn btn-success view_link member_link',
          remote: true if (summary.to_be_updated? || summary.to_be_invoiced? || summary.to_be_altered?) && params[:scope] != 'all'
        item 'Images', alteration_summary_alteration_images_path(summary.id), class: 'btn btn-success', remote: true if summary.images.any?
        item 'Back from alteration', back_from_alteration_alteration_summary_path(summary.id), method: :patch, class: 'btn btn-danger',
          remote: true if summary.to_be_altered? && current_user.inhouse?
      end
    else
      column :id
      column(:customer) { |summary| summary.customer_field }
      column(:type) { |summary| summary.request_type_field }
      column(:urgent) { |summary| summary.urgent_field }
      column(:payment_required) { |summary| summary.payment_required_field }
      column(:violates_validation) { |summary| summary.violates_validation ? 'Yes' : 'No' }
      column(:due_date, sortable: :requested_completion)
      if current_user.admin?
        column(:order_id) do |summary|
          link_to summary.summary_order, order_path(summary.summary_order), remote: true if summary.summary_order
        end
      end
      column('Alteration tailor') { |summary| summary.get_alteration_talors }
      column('Date send to alteration tailor', sortable: 'line_items.sent_to_alteration_date') { |summary| summary.alteration_send_date }
      column('Back From Alteration Tailor') { |summary| summary.alteration_back_date }
      column(:altered_categories) { |summary| summary.altered_categories_field }
      column(:manufacturer_number) { |summary| summary.manufacturer_code }
      column('Alteration costs') { |summary| summary.maybe_amount_link }
      column('Location of Sale') { |summary| summary.locations_of_sales }
      column :invoice_number
      column :invoice_status
      column :created_at
      column :created_by
      column :sales_person
      column :updated_at
      actions defaults: false do |summary|
        item 'Print', summary.pdf_path, class: 'view_link member_link'
        item 'Edit', edit_alteration_summary_path(id: summary.id), class: 'view_link member_link'
        item 'Images', alteration_summary_alteration_images_path(summary.id), class: 'view_link member_link', remote: true if summary.images.any?
      end
    end
  end

  action_item :invoice, only: :index do
    link_to 'Create Invoice', 'javascript:;', class: 'hidden create-invoice-button' if current_user.tailor?
  end

  member_action :services,                method: :get
  member_action :update_services,         method: :patch
  member_action :service_list,            method: :get
  member_action :update_with_alterations, method: :patch
  member_action :back_from_alteration,    method: :patch

  controller do
    def scoped_collection
      current_user.tailor? ? super.list.tailor_summaries(current_user.alteration_tailor_id) : super.list
    end

    def index
      @invoice = Invoice.includes(:alteration_summaries).find_by(id: params[:invoice_id])
      super
    end

    def show
      @summary = AlterationSummary.with_includes.find_by(id: params[:id])
      @categories = Category.visible
      @request_url = params[:request_url]
      @title = 'Alteration PDF'

      respond_to do |format|
        format.pdf do
          render pdf: 'show',
            layout: 'pdf.html.haml',
            zoom: 0.7,
            show_as_html: params.key?('debug')
        end
        format.html do
          render 'show'
        end
      end
    end

    def edit
      @summary      = AlterationSummary.with_includes.with_profile_includes.find_by(id: params[:id])
      @category_ids = @summary.alteration_infos.pluck('alteration_infos.category_id')
      @categories   = Category.all.select(:name, :id, :visible)
      @customer     = @summary.profile.customer.decorate
      @outfitter    = current_user.decorate
      @profile      = @summary.profile.decorate
      @params       = Measurements::Builder.params(category_ids: @category_ids)
      @checks       = MeasurementCheck.all.select(:id, :category_param_id, :min, :max,
                                                  :percentile_of, :calculations_type)
                                      .group_by(&:category_param_id)
      @alterations  = @summary.alterations
      @item_params  = {}

      render 'alteration_summaries/edit', layout: 'application'
    end

    def update
      @summary = AlterationSummary.find(params[:id])
      @summary.update(summary_params)
      respond_with @summary
    end

    def destroy
      @summary = AlterationSummary.find(params[:id])

      Profiles::DeleteAlteration.(@summary, params[:delete_with_revert])
    end

    def update_with_alterations
      @summary = AlterationSummary.find_by(id: params[:id])

      crud = Profiles::Alteration.new(
        params.merge!(
          customer_id: @summary.profile.customer_id,
          profile_id: @summary.profile_id
        ),
        profile_params,
        current_user,
        @summary,
        update: true
      )
      crud.perform

      AlterationSummaries::CRUD.new(
        params: params[:alteration_summary].merge!(
          updater_id: current_user.id,
          request_type: crud.alteration_request_type,
          alteration_images: params[:alteration_images]
        )
      ).update(summary: @summary)
    end

    def services
      @summary = AlterationSummary.find(params[:id])
      @tailor = current_user.alteration_tailor
      category_ids = @summary.altered_category_ids
      @alteration_services = AlterationService.ransack(params[:q]).result
      @services = @tailor.alteration_services.joins(:category).order(:order)
        .select(:id, :category_id, :name, :'alteration_service_tailors.price')
        .where(AlterationServiceTailor.arel_table[:price].gteq(0))
        .where(category_id: category_ids)
        .group_by(&:category_id)
      @categories = Category.all.where(id: category_ids).order(:order)
    end

    def update_services
      @summary = AlterationSummary.find(params[:id])
      already_updated = @summary.service_updated_at
      services = permitted_params[:alteration_summary] || {}
      @summary.update(alteration_service_ids: services[:alteration_service_ids])
      @summary.update_amount(current_user.alteration_tailor_id)
      @summary.will_be_invoiced unless already_updated
    end

    def service_list
      @summary = AlterationSummary.find(params[:id])
      @services = @summary.alteration_services.with_deleted.decorate.group_by(&:category_id)
      @categories = Category.where(id: @services.keys)
    end

    def back_from_alteration
      @summary = AlterationSummary.find(params[:id])
      summary_items = @summary.items.with_state('being_altered')

      if @summary.back_from_alteration
        summary_items.each(&:back_from_alteration!)

        summary_items.update_all(back_from_alteration_date: Time.now)
      end
    end

    private

    def summary_params
      params.require(:alteration_summary).permit(
        :profile_id, :urgent, :request_completion, :requested_completion,
        :alteration_request_taken, :delivery_method, :non_altered_items,
        :remaining_items, :additional_instructions, :request_type,
        :updater_id, :amount, :service_updated_at, :comment_for_tailor
      )
    end

    def profile_params
      params.require(:profile).permit(
        :id, :submitted, :customer_id, :author_id, :submitter_id,
        measurements_attributes: [:id, :value, :allowance, :adjustment,
          :final_garment, :category_param_value_id, :category_param_id,
          :post_alter_garment, :adjustment_value_id,
          alterations_attributes: [:id, :number, :value, :author_id, :measurement_id, :category_param_value_id, :category_id, :alteration_summary_id]],
        images_attributes: [:id, :image, :image_cache, :category_param_value_id]
      )
    end
  end
end
