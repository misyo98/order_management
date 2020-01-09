module LineItems
  module ProfileTriggers
    class Confirmator
      def self.confirm(*attrs)
        new(*attrs).confirm
      end

      def initialize(customer:, user_id:)
        @customer = customer
        @user_id = user_id
      end

      def confirm
        confirmed_category_names = customer.profile.categories_with_states(states: :confirmed)
        items = customer.line_items.with_categories(confirmed_category_names).with_state(:waiting_for_confirmation)

        items.each do |item|
          if item.can_be_confirmed?(profile: customer.profile)
            item.fit_confirmed(user_id: user_id)
          end
        end
      end

      private

      attr_reader :customer, :user_id
    end
  end
end
