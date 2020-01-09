class CategoryParamValue < ActiveRecord::Base
  belongs_to :category_param
  belongs_to :value

  delegate :title, to: :value, prefix: true, allow_nil: true

  def self.find_by_title(title)
    joins(:value).find_by(Value.arel_table[:title].matches(title))
  end
end
