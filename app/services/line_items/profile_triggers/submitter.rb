module LineItems
  module ProfileTriggers
    class Submitter
      def self.submit(*attrs)
        new(*attrs).submit
      end

      def initialize(customer:, user_id:)
        @customer = customer
        @user_id = user_id
      end

      def submit
        submitted_category_names = customer.profile.categories_with_states(states: :submitted)
        items = customer.line_items.with_categories(submitted_category_names).with_states([
          'to_be_reviewed_profile',
          'to_be_submitted_profile'
        ])

        items.each do |item|
          if item.can_be_submitted?(profile: customer.profile)
            item.profile_submission(user_id: user_id)
          end
        end
      end

      private

      attr_reader :customer, :user_id
    end
  end
end
