ActiveAdmin.register CourierCompany do
  menu parent: "Settings", if: -> { can? :index, CourierCompany }

  permit_params :name, :tracking_link

  index title: 'Courier Companies', download_links: -> { can?(:download_csv, CourierCompany) } do
    selectable_column
    id_column
    column :name
    column :tracking_link
    column :created_at
    column :updated_at
    actions
  end
end
