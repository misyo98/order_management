ActiveAdmin.register Tag do
  menu parent: 'Settings', if: -> { can? :index, Tag }

  permit_params :name

  filter :name

  index download_links: false do
    selectable_column
    column(:name) { |tag| link_to tag.name, line_items_path(q: { tags_id_eq: tag.id }) }
    column :created_at
    actions
  end
end
