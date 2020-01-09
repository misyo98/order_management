module Findable
  extend ActiveSupport::Concern

  included do
    scope :find_by_query, ->(query, subquery = '') do 
      where(matches_email(query, subquery).or(matches_first_name(query, subquery)).or(matches_last_name(query, subquery)))
      .limit(80).order(created_at: :desc)
    end
  end

  module ClassMethods
    def matches_email(query, subquery)
      arel_table[:email].matches("%#{query}%").or(arel_table[:email].matches("%#{subquery}%"))
    end

    def matches_first_name(query, subquery) 
      arel_table[:first_name].matches("%#{query}%").or(arel_table[:first_name].matches("%#{subquery}%"))
    end

    def matches_last_name(query, subquery) 
      arel_table[:last_name].matches("%#{query}%").or(arel_table[:last_name].matches("%#{subquery}%"))
    end
  end
end