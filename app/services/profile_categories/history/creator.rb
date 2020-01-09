module ProfileCategories
  module History
    class Creator
      def self.create(*args)
        new(*args).create
      end

      def initialize(profile_category, author_id)
        @profile_category = profile_category
        @author_id = author_id
      end

      def create
        ProfileCategoryHistory.create(
          profile_category: profile_category,
          author_id: author_id,
          status: profile_category.status
        )
      end

      private

      attr_reader :profile_category, :author_id
    end
  end
end
