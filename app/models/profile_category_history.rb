# frozen_string_literal: true

class ProfileCategoryHistory < ActiveRecord::Base
  TO_BE_FIXED = 'to_be_fixed'

  belongs_to :profile_category
  belongs_to :author, class_name: 'User'

  def self.second_to_last_event_status
    select_previous_event_status(1)
  end

  private

  def self.select_previous_event_status(offset)
    previous_event_status = select(:status).order(id: :desc).offset(offset).limit(1).first&.status

    if previous_event_status == TO_BE_FIXED
      select_previous_event_status(offset + 1)
    else
      previous_event_status
    end
  end
end
