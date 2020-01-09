ActiveAdmin.register AlterationSummary, as: 'Alteration Not Update' do
  decorate_with AlterationSummaryDecorator

  menu parent: "Alterations", label: 'Not Updated', if: -> { can? :not_updated, AlterationSummary }
  actions :all, except: [:destroy, :edit, :new]

  before_action :right_sidebar!

  filter :customer_name_match, label: 'Customer name', as: :string
  filter :due_date, as: :date_range
  filter :urgent
  filter :manufacturer_number_match, label: 'Manufacturer Number', as: :string
  filter :created_by_match, label: 'Created by', as: :string

  index(title: 'Not Updated Alterations', download_links: -> { can?(:download_csv, AlterationSummary) }) do
    column :id
    column(:customer) { |summary| summary.customer_field }
    column(:type) { |summary| summary.request_type_field }
    column(:urgent) { |summary| summary.urgent_field }
    column :due_date, sortable: :requested_completion
    column(:back_from_alteration_tailor) { |summary| summary.alteration_back_date }
    column(:altered_categories) { |summary| summary.altered_categories_field }
    column(:manufacturer_number) { |summary| summary.alteration_infos.first.manufacturer_code }
    column("Location of Sale") { |summary| summary.locations_of_sales }
    column :created_at
    column :created_by
    column :updated_at
    actions defaults: false do |summary|
      item "Print", summary.pdf_path, class: 'view_link member_link'
      item "Edit", edit_alteration_summary_path(id: summary.id), class: 'view_link member_link'
    end
  end

  controller do
    def scoped_collection
      super.list.to_be_updated.joins(:items).merge(LineItem.alteration_back)
    end
  end
end
