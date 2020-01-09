module LineItems
  module ProfileTriggers
    class ToBeSubmitter
      def self.to_be_submitted(*attrs)
        new(*attrs).to_be_submitted
      end

      def initialize(customer:, user_id:)
        @customer = customer
        @user_id = user_id
      end

      def to_be_submitted
        to_be_submitted_category_names = customer.profile.categories_with_states(states: :to_be_submitted)
        items =
          customer.line_items.with_categories(to_be_submitted_category_names).with_states([
            'to_be_checked_profile',
            'to_be_fixed_profile'
          ])

        items.each do |item|
          if item.can_be_prepared_for_submission?(profile: customer.profile)
            item.saved_to_be_submitted(user_id: user_id)
          end
        end
      end

      private

      attr_reader :customer, :user_id
    end
  end
end
