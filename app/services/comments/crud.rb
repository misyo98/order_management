module Comments
  class CRUD
    def initialize(params: {})
      @params = params
      @submission = convert_to_boolean(value: params.fetch(:submission, false))
      @category_ids = form_category_ids
      @comments = []
    end

    def create
      perform_creation
    end

    def create_bulk
      perform_bulk_creation
    end

    private

    attr_reader   :submission, :category_ids
    attr_accessor :params, :comments

    def form_category_ids
      ids = params.delete(:category_ids)
      ids = ids.split(',').map(&:to_i) if ids
    end

    def perform_creation
      new_ids = get_new_ids
      form_comments(ids: new_ids)
      save
    end

    def perform_bulk_creation
      params.each do |index, comment_hash|
        comments << ActiveAdmin::Comment.new(comment_params(comment: comment_hash))
      end
      save
    end

    def get_new_ids
      existing_ids = ActiveAdmin::Comment.where(
        resource_type: params[:resource_type], 
        resource_id: params[:resource_id],
        submission: submission,
        category_id: category_ids
        ).pluck(:category_id)
      category_ids - existing_ids
    end

    def form_comments(ids: [])
      ids.each do |category_id|
        comments << ActiveAdmin::Comment.new(params.merge!(category_id: category_id))
      end
    end

    def convert_to_boolean(value:)
      value == 'true'
    end

    def save
      ActiveAdmin::Comment.import comments, validate: false, on_duplicate_key_update: [:body, :submission, :updater_id]
    end

    def comment_params(comment:)
      comment.permit(:body, :namespace, :resource_id, :category_id, :category_ids,
                     :resource_type, :author_id, :updater_id, :author_type, :submission, :id)
    end
  end
end