# frozen_string_literal: true

module Exporters
  class Objects::Measurements < Exporters::Base
    def initialize(profiles:)
      @profiles         = profiles
      @row_index        = 0
      @profiles_count   = profiles.size.to_f
      @current_progress = 0
      @updated_progress = 0
      @categories       = Category.select(:id, :name).includes(category_params: :param)
      @category_params  = CategoryParam.all
      @body_category    = categories.detect { |category| category.name == 'Body shape & postures' }
    end

    private

    attr_reader :profiles, :row_index, :profiles_count, :updated_progress, :categories,
                :category_params, :body_category, :current_progress

    def process
      CSV.generate(headers: true) do |csv|
        csv << build_headers

        threads = []

        threads << Thread.new do
          profiles.find_each(batch_size: 100) do |profile|
            csv << ([profile.customer_id, profile.customer&.full_name] + collect_measurement_fields(profile))

            progress_result
          end
        end

        threads.each(&:join)
      end
    end

    def collect_measurement_fields(profile)
      categories.each_with_object([]) do |category, category_fields|
        category_fields << resolve_fit(profile, category.id)

        category_fields << resolve_profile_category(profile, category.id)

        category_fields << resolve_comment(profile, category.id)

        category.category_params.each do |category_param|
          measurement = select_measurement(profile, category_param.id)

          if category_param.category_id == body_category.id
            category_fields << measurement&.category_param_value&.value&.title
            category_fields << resolve_body_alter_value(measurement)
          else
            category_fields << measurement&.value
            category_fields << measurement&.allowance
            category_fields << resolve_alter_value(measurement)
          end
        end
      end
    end

    def resolve_fit(profile, category_id)
      profile.fits&.detect { |fit| fit.category_id == category_id }&.fit
    end

    def resolve_profile_category(profile, category_id)
      profile.categories&.detect { |profile_category| profile_category.category_id == category_id }&.status
    end

    def resolve_comment(profile, category_id)
      profile.customer&.comments&.detect { |comment| comment.category_id == category_id && comment.body.present? }&.body&.squish&.gsub(';', ',')
    end

    def select_measurement(profile, category_param_id)
      profile.measurements&.detect { |measurement| measurement.category_param_id == category_param_id }
    end

    def resolve_body_alter_value(measurement)
      measurement&.adjustment_value_id ? measurement&.adjustment_value&.value_title : measurement&.category_param_value&.value&.title
    end

    def resolve_alter_value(measurement)
      measurement&.alterations&.any? ? measurement&.post_alter_garment : measurement&.final_garment
    end

    def build_headers
      headers = []

      headers << 'Customer ID'
      headers << 'Customer Name'

      categories.each do |category|
        headers << "#{category.name} Fit"
        headers << "#{category.name} Status"
        headers << "#{category.name} Comment"

        category.category_params.each do |category_param|
          if category_param.category_id == body_category.id
            headers << "#{category.name} #{category_param.param.title} - Body"
            headers << "#{category.name} #{category_param.param.title} - Final"
          else
            headers << "#{category.name} #{category_param.param.title} - Body"
            headers << "#{category.name} #{category_param.param.title} - Allowance"
            headers << "#{category.name} #{category_param.param.title} - Final"
          end
        end
      end

      headers
    end

    def current_progress_percentage(row_index)
      ((row_index.to_f / profiles_count) * 100).round(0)
    end

    def progress_result
      @row_index += 1

      @current_progress = current_progress_percentage(row_index)

      if current_progress > updated_progress
        Thread.new do
          begin
            @updated_progress = current_progress

            Pusher.trigger('measurements-csv-progress-channel', 'measurements-csv-progress-event', {
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
