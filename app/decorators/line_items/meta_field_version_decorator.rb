module LineItems
  class MetaFieldVersionDecorator < Draper::Decorator
    DATE_FORMAT = '%m/%d/%Y'.freeze

    delegate_all

    def resolve_step
      meta_change_step
    end

    def username
      whodunnit
    end

    def date
      created_at.strftime(DATE_FORMAT)
    end

    def empty_state
      nil
    end

    def self.column_names
      %i(object_changes whodunnit created_at)
    end

    %i(display_tailor? display_courier?).each do |aliased_method|
      alias_method aliased_method, :empty_state
    end

    private

    def from_yaml(value)
      return if value.nil?

      ::YAML.load(value)
    end

    def meta_change_step
      changes = new_values - old_values
      changes.inject([]) do |changes, new_value|
        value_key = new_value['key']
        changes << "#{value_key} value was changed from: #{find_old_value(value_key)}, to: #{new_value['value']}"
        changes
      end.join('; ')
    end

    def old_values
      old_values ||= from_yaml(changeset&.dig(:meta)&.dig(0)) || []
    end

    def new_values
      new_values ||= from_yaml(changeset&.dig(:meta)&.dig(1)) || []
    end

    def find_old_value(key)
      old_value_hash = old_values.find { |meta_hash| meta_hash.dig('key') == key }
      old_value_hash&.dig('value')
    end
  end
end
