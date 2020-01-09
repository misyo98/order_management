ActiveAdmin.register AlterationTailor do
  decorate_with AlterationTailorDecorator
  
  menu parent: "Settings", if: -> { can? :index, AlterationTailor }
  permit_params :name, :currency

  index title: 'Alteration Tailors', download_links: -> { can?(:download_csv, AlterationTailor) }, decorate: true do
    selectable_column
    id_column
    column :name
    column :created_at
    column :updated_at
    column(:currency) { |tailor| tailor.formatted_currency }
    actions
  end
end
