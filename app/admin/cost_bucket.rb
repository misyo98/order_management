ActiveAdmin.register CostBucket do
  menu parent: "Accountings", if: -> { can? :index, CostBucket } 

  permit_params :label

  index(title: 'Cost Buckets', download_links: -> { can?(:download_csv, CostBucket) }) do
    selectable_column
    id_column
    column :label
    column :created_at
    column :updated_at
    actions
  end
end
