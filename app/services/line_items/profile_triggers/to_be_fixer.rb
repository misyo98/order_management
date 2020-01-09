module LineItems
  module ProfileTriggers
    class ToBeFixer
      def self.to_be_fixed(*attrs)
        new(*attrs).to_be_fixed
      end

      def initialize(customer:, user_id:)
        @customer = customer
        @user_id = user_id
      end

      def to_be_fixed
        to_be_fixed_category_names = customer.profile.categories_with_states(states: :to_be_fixed)
        items =
          customer.line_items.with_categories(to_be_fixed_category_names).with_states([
            'to_be_submitted_profile',
            'to_be_reviewed_profile',
            'to_be_checked_profile'
          ])

        items.each do |item|
          if item.can_be_fixed?(profile: customer.profile)
            item.reviewed_not_ok(user_id: user_id)
          end
        end
      end

      private

      attr_reader :customer, :user_id
    end
  end
end
