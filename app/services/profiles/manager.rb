module Profiles
  class Manager
    def initialize(params: {}, user:, profile_params: {})
      @params  = params
      @user    = user #current_user
      @profile = Profile.find_or_initialize_by(customer_id: params[:customer_id])
      @customer = profile.customer
      @success = false
      @profile_params = profile.new_record? ? profile_params.merge({ author: user }) : profile_params
      @submitted_categories = get_submitted_categories
      @altered_category_ids = []
    end

    def create_or_update
      if profile.update(profile_params)
        create_profile_categories(status: params[:requested_state_transition])
        trigger_profile_categories_state
        trigger_items_depending_on_requested_action
        submit_fits if requested_state?('submitted')
        save_comments
        save_images
        maybe_send_notification_about_required_fixes
        success = true
      end
      profile
    end

    def success?
      success
    end

    private

    attr_reader   :user, :params, :submitted_categories, :profile_params
    attr_accessor :success, :profile, :altered_category_ids, :customer

    def save_images
      if params[:images_attributes]
        params[:images_attributes][:image].each do |image|
          profile.images.create!(image: image)
        end
      end
    end

    def create_profile_categories(status: 'to_be_checked')
      ProfileCategories::CRUD.new(
        profile_id: profile.id,
        category_ids: submitted_categories,
        user_id: user.id,
        fitting_garments: params[:fitting_garments]
      ).create(status: status)
    end

    def requested_state?(state)
      params[:requested_state_transition] == state
    end

    def save_comments
      Comments::CRUD.new(params: params[:comments]).create_bulk
    end

    def trigger_profile_categories_state
      profile.categories.unsubmitted.each do |category|
        status_changed = category.status != params[:requested_state_transition]

        category.send("#{params[:requested_state_transition]}!")

        ProfileCategories::History::Creator.create(category, user.id) if status_changed
      end
    end

    def get_submitted_categories
      return [] unless params.dig(:profile, :measurements_attributes)

      category_param_ids = params[:profile][:measurements_attributes].each_with_object([]) do |param_array, array|
        array << param_array[1][:category_param_id]
      end
      CategoryParam.find_categories(category_param_ids: category_param_ids)
    end

    def submit_fits
      category_ids = profile.measurements.joins(category_param: :category).pluck('categories.id').uniq
      profile.fits.where(category_id: category_ids).update_all(submitted: true)
    end

    def trigger_items_depending_on_requested_action
      case
      when requested_state?('submitted')
        LineItems::ProfileTriggers::Submitter.submit(customer: customer, user_id: user.id)
      when requested_state?('to_be_checked')
        LineItems::ProfileTriggers::ToBeChecker.to_be_checked(customer: customer, user_id: user.id)
      when requested_state?('to_be_fixed')
        LineItems::ProfileTriggers::ToBeFixer.to_be_fixed(customer: customer, user_id: user.id)
      when requested_state?('to_be_reviewed')
        LineItems::ProfileTriggers::ToBeReviewer.to_be_reviewed(customer: customer, user_id: user.id)
      when requested_state?('to_be_submitted')
        LineItems::ProfileTriggers::ToBeSubmitter.to_be_submitted(customer: customer, user_id: user.id)
      end
    end

    def maybe_send_notification_about_required_fixes
      if requested_state?('to_be_fixed')
        profile.categories.to_be_fixed.map(&:author).uniq.each do |author|
          ProfileMailer.notify_about_to_be_fixed_profiles(user: author).deliver_now
        end
      end
    end
  end
end
