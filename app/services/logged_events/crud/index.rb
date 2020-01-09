module LoggedEvents
  module CRUD
    class Index
      def self.call(*args)
        new(*args).call
      end

      def initialize(line_item)
        @line_item = line_item
      end

      def call
        decorated_logged_events = line_item.logged_events.decorate
        versions = line_item.versions.where(meta_fields_changed: true).select(:object_changes, :whodunnit, :created_at)
        decorated_versions = LineItems::MetaFieldVersionDecorator.decorate_collection(versions)
        (decorated_logged_events + decorated_versions).sort_by(&:created_at)
      end

      private

      attr_reader :line_item
    end
  end
end
