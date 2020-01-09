module Importers
  class Objects::DropdownListValues < Importers::Base
    DROPWDOWN_LIST_VALUE_ATTRIBUTES = {
      order:              'Order',
      dropdown_list_id:   'Dropdown List',
      title:              'Gravity Form Name',
      manufacturer_code:  'Manufacturer Code',
      price_sgd:          'Price (SGD)',
      price_gbp:          'Price (GBP)',
      manufacturer:       'Manufacturer',
      tuxedo:             'Tuxedo'
    }.freeze

    ALLOWED_MANUFACTURERS = %w(blank_m old_m new_m)
    ALLOWED_TUXEDO_SELECTION = %w(tuxedo_all tuxedo_yes tuxedo_no)
    ALLOWED_TUXEDOS = {
      'all' => :tuxedo_all,
      'yes' => :tuxedo_yes,
      'no' => :tuxedo_no
    }

    def initialize(file:)
      @file                      = file
      @old_dropdown_list_values  = FabricOptionValue.for_dropdown_list.map(&:title)
      @new_dropdown_list_values  = []
      @rows_count                = File.open(file.path).readlines.size
    end

    private

    attr_reader :file, :old_dropdown_list_values, :new_dropdown_list_values, :rows_count

    private

    def process
      CSV.foreach(file.path, headers: true, quote_char: "\"", row_sep: :auto, col_sep: ',') do |row|
        attributes = scrape_attributes(line: row.to_hash, attributes_hash: DROPWDOWN_LIST_VALUE_ATTRIBUTES)

        next if attributes[:title].blank?

        option_value = FabricOptionValue.find_by(title: attributes[:title].strip)
        formatted_attributes = format_fabric_attributes(attributes)

        if option_value
          option_value.assign_attributes(formatted_attributes)
        else
          option_value = FabricOptionValue.new(formatted_attributes.merge(active: true))
        end

        new_dropdown_list_values << option_value.title

        option_value.save(validate: false)
      end

      remove_unused
      result(success: true, count: rows_count)
    end

    def format_fabric_attributes(attributes)
      attributes[:dropdown_list_id] = DropdownList.find_by(title: attributes[:dropdown_list_id])&.id
      attributes[:manufacturer] = attributes[:manufacturer]&.underscore.in?(ALLOWED_MANUFACTURERS) ? attributes[:manufacturer]&.underscore : nil
      attributes[:tuxedo] = ALLOWED_TUXEDOS[attributes[:tuxedo]&.strip&.downcase]
      attributes[:price] = { 'SGD' => attributes[:price_sgd], 'GBP' => attributes[:price_gbp] }
      attributes.delete(:price_sgd)
      attributes.delete(:price_gbp)

      attributes
    end

    def remove_unused
      unused_dropdown_list_values = old_dropdown_list_values - new_dropdown_list_values

      FabricOptionValue.for_dropdown_list.where(title: unused_dropdown_list_values)
        .destroy_all if unused_dropdown_list_values.any?
    end

    def to_true_or_false(param)
      return false unless param

      param.strip.downcase == 'yes' ? true : false
    end

    def find_value(pattern:, line:)
      line.find { |key, value| key.strip == pattern }&.dig(1)
    end
  end
end
