module ActiveAdmin::ViewsHelper
  def find_comment(array:, submission:)
    return unless array
    array.find { |comment| comment.submission == submission }
  end

  def to_yes_or_no(boolean)
    boolean ? 'Yes' : 'No'
  end
end
