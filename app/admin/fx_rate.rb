ActiveAdmin.register FxRate do
  menu label: 'FX Rates', parent: 'Accountings', if: -> { can? :index, FxRate }
  
  permit_params :usd_gbp, :usd_sgd, :usd_eur, :valid_from

  form do |f|
    inputs 'Details' do
      input :usd_gbp, label: 'USD / GBP'
      input :usd_sgd, label: 'USD / SGD'
      input :usd_eur, label: 'USD / EUR'
      input :valid_from, as: :datepicker
    end
    actions
  end

  index title: 'FX Rates', download_links: -> { can?(:download_csv, FxRate) } do
    selectable_column
    id_column
    column('USD/GBP', humanize_name: false) { |rate| rate.usd_gbp }
    column('USD/SGD', humanize_name: false) { |rate| rate.usd_sgd }
    column('USD/EUR', humanize_name: false) { |rate| rate.usd_eur }
    column :valid_from
    actions
  end
end
