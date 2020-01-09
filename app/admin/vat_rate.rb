ActiveAdmin.register VatRate do
  menu parent: "Accountings", if: -> { can? :index, VatRate }

  permit_params :shipping_country, :rate, :valid_from

  form do |f|
    inputs 'Details' do
      input :shipping_country, as: :select, collection: ApplicationHelper::COUNTRIES_FOR_SELECT
      input :rate
      input :valid_from, as: :datepicker
    end
    actions
  end

  index title: 'Vat Rates', download_links: -> { can?(:download_csv, VatRate) } do
    selectable_column
    id_column
    column :shipping_country
    column :rate
    column :valid_from
    column :created_at
    column :updated_at
    actions
  end
end
