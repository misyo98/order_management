ActiveAdmin.register Allowance do
  menu priority: 5, if: -> { can? :edit, Allowance }
  before_filter :right_sidebar!

  permit_params :slim, :singapore_slim, :regular, :classic, :self_slim, :self_regular, :id

  index download_links: -> { can?(:download_csv, Allowance) } do
    selectable_column
    id_column
    column(:name) { |allowance| "#{allowance.category_param&.category_name} #{allowance.category_param&.param_title}" }
    column :slim
    column :singapore_slim
    column :regular
    column :classic
    column :self_slim
    column :self_regular
    actions
  end

  controller do
    def scoped_collection
      super.joins(:category_param)
    end
  end
end
