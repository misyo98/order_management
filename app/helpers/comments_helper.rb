module CommentsHelper

  def resolve_comment_object(objects:, category_id:)
    comment = objects.detect { |comment| comment.category_id == category_id }
    comment ? comment : ActiveAdmin::Comment.new
  end
end