class CommentsDecorator < Draper::Decorator
  RED_CLASS = 'red-field'.freeze
  DATE_PATTERN = '%B %d, %Y'.freeze

  delegate_all

  def find_and_decorate_comment(category_id, submission)
    comment = find { |comment| comment.category_id == category_id && comment.submission == submission }
    self.class.decorate(comment) if comment
  end

  def maybe_red_class
    RED_CLASS if body.present?
  end

  def creation_date
    created_at&.strftime(DATE_PATTERN)
  end

  def update_date
    updated_at&.strftime(DATE_PATTERN)
  end
end
