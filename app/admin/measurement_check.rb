ActiveAdmin.register MeasurementCheck do
  menu parent: 'Settings', if: -> { current_user.admin? }

  config.sort_order = 'id_asc'
  config.filters = false

  actions :all, except: [:new, :show, :destroy]

  permit_params :min_percentile, :max_percentile

  index do
    id_column
    column('Measurement', humanize_name: false) { |check| check.category_param.to_s }
    column('Height Clusters', humanize_name: false) do |check|
      check.height_clusters.map do |cluster|
        "Height limit: #{cluster.upper_limit}. Min: #{cluster.min}; Max: #{cluster.max}"
      end.push("Defaults: Min: #{check.min}; Max: #{check.max}").join('<br>').html_safe
    end
    column(:percentile_of) { |check| check.percentile_of&.humanize }
    column(:min_percentile)
    column(:max_percentile)
    actions
  end

  form do |f|
    f.inputs do
      f.input :min_percentile
      f.input :max_percentile
    end
    f.submit
  end

  controller do
    def scoped_collection
      super.includes(:height_clusters, :category_param).without_blank_params
    end

    def index
      respond_to do |format|
        format.json { respond_with MeasurementChecks::Fetcher.fetch(params[:height]).to_json }
        format.html { super }
        format.js { super }
      end
    end

    def update
      super
      UpdateChecks.perform_async([@measurement_check.category_param_id])
    end
  end
end
