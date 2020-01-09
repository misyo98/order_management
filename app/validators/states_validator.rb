module StatesValidator
  def can_be_reviewed?(profile:)
    return false unless local_category
    if :saved_to_be_reviewed.in? state_events
      return profile.have_categories_with_state?(item_categories: local_category, states: :to_be_reviewed)
    end
    false
  end

  def can_be_fixed?(profile:)
    return false unless local_category
    if :reviewed_not_ok.in? state_events
      return profile.have_categories_with_state?(item_categories: local_category, states: :to_be_fixed)
    end
    false
  end

  def can_be_checked?(profile:)
    return false unless local_category
    if :saved_to_be_checked.in? state_events
      return profile.have_categories_with_state?(item_categories: local_category, states: :to_be_checked)
    end
    false
  end


  def can_be_prepared_for_submission?(profile:)
    return false unless local_category
    if :saved_to_be_submitted.in? state_events
      return profile.have_categories_with_state?(item_categories: local_category, states: :to_be_submitted)
    end
    false
  end

  def can_be_submitted?(profile:)
    return false unless local_category
    if :profile_submission.in? state_events
      return profile.have_categories_with_state?(item_categories: local_category, states: [:submitted, :confirmed])
    end
    false
  end

  def can_be_confirmed?(profile:)
    return false unless local_category
    if :fit_confirmed.in? state_events
      return profile.have_categories_with_state?(item_categories: local_category, states: :confirmed)
    end
    false
  end
end
