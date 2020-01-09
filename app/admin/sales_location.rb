ActiveAdmin.register SalesLocation do
  menu parent: "Settings", if: -> { can? :index, SalesLocation }
  config.filters = false

  permit_params :name, :showroom_address, :delivery_calendar_link, :email_from

  index download_links: -> { can?(:download_csv, SalesLocation) } do
    selectable_column
    id_column
    column :name
    column :showroom_address
    column :email_from
    column :delivery_calendar_link
    column :created_at
    column :updated_at
    actions
  end
end
