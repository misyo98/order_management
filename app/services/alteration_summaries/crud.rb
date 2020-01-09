module AlterationSummaries
  class CRUD

    def initialize(params: {})
      @params = params
      @image_params = params[:alteration_images]
    end

    def create
      summary = AlterationSummary.create(summary_params)
      summary.line_item_ids.each { |item_id| summary.alteration_summary_line_items.create(line_item_id: item_id) }
      create_images(summary)
      summary
    end

    def update(summary:)
      create_images(summary)
      summary.update(summary_params)
    end

    private

    attr_reader :params, :image_params

    def summary_params
      params.permit(
        :urgent, :payment_required, :requested_completion, :alteration_request_taken, :delivery_method,
        :non_altered_items, :remaining_items, :additional_instructions, :request_type,
        :profile_id, :updater_id, :violates_validation, { image: [] }, line_item_ids: [])
    end

    def create_images(summary)
      if image_params
        image_params[:image].each { |image| AlterationImage.create(image: image, alteration_summary_id: summary.id) }
      end
    end
  end
end
