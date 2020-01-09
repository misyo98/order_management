ActiveAdmin.register Invoice do
  menu parent: 'Alterations', label: 'Invoices'

  actions :all, except: [:edit, :new]

  permit_params :payment_date, :status, alteration_summary_ids: []

  filter :status, as: :select, collection: Invoice.statuses.map { |status, value| [status.humanize, value] }
  filter :payment_date
  filter :created_at

  index download_links: -> { can?(:download_csv, Invoice) } do
    column('Number') { |invoice| invoice.id }
    column('Tailor') { |invoice| invoice.alteration_tailor&.name }
    column('Status') { |invoice| invoice.status.humanize }
    column :payment_date
    column :created_at
    actions defaults: false do |invoice|
      if invoice.invoiced?
        item 'Mark as Paid', new_paid_invoice_path(invoice.id), class: 'view_link member_link mark-as-paid', remote: true unless current_user.tailor?
        item 'Edit', alteration_summaries_path(invoice_edit: true, invoice_id: invoice.id, scope: :invoiced), class: 'view_link member_link' if current_user.tailor?
      elsif invoice.paid? && invoice.files.first
        item 'Transaction Slip', invoice.files.first.attachment.url, class: 'view_link member_link', target: '_blank'
      end
      item 'View', view_invoice_path(id: invoice.id, format: :pdf), class: 'view_link member_link'
      item 'Delete', invoice_path(id: invoice.id), method: :delete, class: 'view_link member_link' if can?(:destroy, invoice)
    end
  end

  show do
    attributes_table do
      row('Number') { |invoice| invoice.id }
      row('Tailor') { |invoice| invoice.alteration_tailor.name }
      row('Status') { |invoice| invoice.status.humanize }
      row :payment_date
      row('Transaction Slip') do |invoice|
        image_tag invoice.files.first.attachment.url, width: '50px', height: '50px' if invoice.files.first
      end
      row :created_at
    end
  end

  action_item :alteration, only: :show do
    if invoice.invoiced? && current_user.tailor?
      link_to 'Edit', alteration_summaries_path(invoice_edit: true, invoice_id: invoice.id), class: 'view_link member_link'
    end
  end

  member_action :add_summary, method: :patch
  member_action :remove_summary, method: :delete
  member_action :new_paid, method: :get
  member_action :view, method: :get

  controller do
    def scoped_collection
      current_user.tailor? ? super.for_tailor(current_user.alteration_tailor_id) : super
    end

    def create
      @invoice = Invoice.new(
        permitted_params[:invoice].merge(
          alteration_tailor_id: current_user.alteration_tailor_id
        )
      )
      @invoice.save
      @invoice.alteration_summaries.each { |summary| summary.invoiced! }
    end

    def update
      @invoice = Invoice.find_by(id: params[:id])
      @invoice.assign_attributes(permitted_params[:invoice])
      @invoice.files.build(attachment: params[:invoice][:file]) if params[:invoice][:file]

      @invoice.save
      @invoice.alteration_summaries.each { |summary| summary.got_paid! }
    end

    def destroy
      @invoice = Invoice.find_by(id: params[:id])
      @invoice.alteration_summaries.each(&:removed_invoice!)
      super
    end

    def add_summary
      @invoice = Invoice.find_by(id: params[:id])
      summary = AlterationSummary.find_by(id: params[:alteration_summary_id])
      summary.invoiced! unless summary.invoiced?
      @invoice.alteration_summaries << summary
    end

    def remove_summary
      @invoice = Invoice.find_by(id: params[:id])
      AlterationSummary.find(params[:alteration_summary_id]).removed_invoice!
      @invoice.alteration_summaries.delete(params[:alteration_summary_id])
    end

    def new_paid
      @invoice = Invoice.find_by(id: params[:id])
    end

    def view
      @invoice = Invoice.find_by(id: params[:id])
      @title = 'INVOICE FOR ALTERATION SERVICES'

      render pdf: 'view',
             layout: 'pdf.html.haml',
             zoom: 0.7,
             show_as_html: params.key?('debug')
    end
  end
end
