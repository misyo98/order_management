module Importers
  class Objects::FittingGarments < Importers::Base
    FITTING_GARMENT_ATTRIBUTES = {
      order:    'Order',
      name:     'Name',
      category: 'Category',
      country:  'Country'
    }.freeze

    def initialize(tempfile_path:)
      @tempfile_path    = tempfile_path
      @categories       = Category.all.each_with_object({}) { |category, categories_hash| categories_hash[category.name] = category }
      @category_params  = CategoryParam.includes(:param).all
      @rows_count       = CSV.readlines(tempfile_path).uniq.delete_if { |row| row.all? { |column| column.nil? } }.size - 1 #ignoring headers row and empty row for some encodings
      @row_index        = 0
      @updated_progress = 0
    end

    private

    attr_reader :tempfile_path, :categories, :category_params, :rows_count, :row_index, :updated_progress

    def process
      CSV.foreach(tempfile_path, headers: true, quote_char: "\"", row_sep: :auto, col_sep: ',') do |row|
        attributes = scrape_attributes(line: row.to_hash, attributes_hash: FITTING_GARMENT_ATTRIBUTES)

        next if attributes[:name].blank?

        fitting_category = categories[attributes[:category]]
        fitting_garment = resolve_fitting_garment(attributes: attributes)

        fitting_garment.save

        row.each do |header, value|
          if header.include?(fitting_category.name.upcase)
            param_title = header.gsub("#{fitting_category.name.upcase}, ", '')
            category_param = resolve_category_param(fitting_category, param_title)

            resolve_fitting_measurement(fitting_garment, category_param, value)
          end
        end

        progress_result
      end

      pusher_success_import
    end

    def resolve_fitting_garment(attributes: {})
      fitting_garment = FittingGarment.find_by(name: attributes[:name], category: categories[attributes[:category]].id)

      if fitting_garment.present?
        fitting_garment.tap { |garment| garment.order = attributes[:order]}
      else
        attributes.tap { |params| params[:category] = categories[params[:category]] }

        FittingGarment.new(attributes)
      end
    end

    def resolve_category_param(fitting_category, param_title)
      category_params.detect { |c_p| c_p.category_id == fitting_category.id && c_p.param.title == param_title }
    end

    def resolve_fitting_measurement(fitting_garment, category_param, value)
      measurement = fitting_garment.fitting_garment_measurements.find_or_initialize_by(category_param_id: category_param.id)
      measurement.value = value.presence

      measurement.save
    end

    def pusher_success_import
      Thread.new do
        begin
          Pusher.trigger('fitting-garments-import-channel', 'fitting-garments-imported-event', {
            message: 'Successfully imported Fitting Garments.'
          })
        rescue Pusher::Error => error
          puts "#{DateTime.current}: Pusher error - #{error.message}"
        end
      end
    end

    def current_progress_percentage(row_index)
      ((row_index.to_f / rows_count.to_f) * 100).round(0)
    end

    def progress_result
      @row_index += 1
      current_progress = current_progress_percentage(row_index)

      if current_progress > updated_progress
        Thread.new do
          begin
            @updated_progress = current_progress
            Pusher.trigger('fitting-garments-import-progress-channel', 'fitting-garments-import-progress-event', {
              progress: updated_progress
            })
          rescue Pusher::Error => error
            puts "#{DateTime.current}: Pusher error - #{error.message}"
          end
        end
      end
    end
  end
end
