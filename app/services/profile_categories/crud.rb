module ProfileCategories
  class CRUD
    def initialize(args)
      @categories           = args.fetch :category_ids, []
      @profile_id           = args.fetch :profile_id, 0
      @profile_categories   = args.fetch :profile_categories, []
      @user_id              = args.fetch :user_id, 0
      @fitting_garments     = args.fetch :fitting_garments, {}
    end

    def create(status:)
      prepared_categories = prepared_profile_categories(status: status)

      result = ProfileCategory.import prepared_categories
      existing_categories = result.failed_instances.map(&:category_id)

      Profile.find_by(id: profile_id).categories.where(category_id: categories).each do |category|
        next if category.category_id.in?(existing_categories)

        ProfileCategories::History::Creator.create(category, user_id)
      end
    end

    def submit
      profile_categories.each do |category|
        if category.to_be_submitted? || category.to_be_reviewed?
          category.submitted!

          ProfileCategories::History::Creator.create(category, user_id)
        end
      end
    end

    def update_states
      profile_categories.each do |profile_category_id, param_hash|
        profile_category = ProfileCategory.find_by(id: profile_category_id)
        profile_category.update_attribute(:status, ProfileCategory.statuses[param_hash[:status]])

        ProfileCategories::History::Creator.create(profile_category, user_id)
        trigger_items_state(profile: profile_category.profile, status: param_hash[:status])
      end
      true
    end

    private

    attr_reader   :categories, :profile_id, :user_id, :fitting_garments
    attr_accessor :profile_categories

    def prepared_profile_categories(status:)
      categories.inject([]) do |array, category_id|
        array << ProfileCategory.new(
          profile_id: profile_id,
          category_id: category_id,
          status: status,
          author_id: user_id,
          fitting_garment_id: fitting_garments&.dig(category_id.to_s)
        )
      end
    end

    def trigger_items_state(profile:, status:)
      case
      when status == 'to_be_checked'
        LineItems::ProfileTriggers::ToBeChecker.to_be_checked(customer: profile.customer, user_id: user_id)
      when status == 'to_be_fixed'
        LineItems::ProfileTriggers::ToBeFixer.to_be_fixed(customer: profile.customer, user_id: user_id)
      when status == 'to_be_reviewed'
        LineItems::ProfileTriggers::ToBeReviewer.to_be_reviewed(customer: profile.customer, user_id: user_id)
      when status == 'to_be_submitted'
        LineItems::ProfileTriggers::ToBeSubmitter.to_be_submitted(customer: profile.customer, user_id: user_id)
      when status == 'submitted'
        LineItems::ProfileTriggers::Submitter.submit(customer: profile.customer, user_id: user_id)
      when status == 'confirmed'
        LineItems::ProfileTriggers::Confirmator.confirm(customer: profile.customer, user_id: user_id)
      end
    end
  end
end
