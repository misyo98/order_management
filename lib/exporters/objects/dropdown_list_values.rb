module Exporters
  class Objects::DropdownListValues < Exporters::Base
    private

    def process
      fast_fields_xls
    end

    def fast_fields_xls
      CSV.generate(headers: true) do |csv|
        unless options[:no_header]
          csv << [
            'Order',
            'Dropdown List',
            'Gravity Form Name',
            'Manufacturer Code',
            'Price (SGD)',
            'Price (GBP)',
            'Manufacturer',
            'Active',
            'Tuxedo'
          ]
        end

        records.each do |record|
          csv << [
            record.order,
            record.dropdown_list&.title,
            record.title,
            record.manufacturer_code,
            record.price&.dig('SGD'),
            record.price&.dig('GBP'),
            record.manufacturer,
            to_yes_or_no(record.active?),
            FabricOptionValue::TUXEDO_SELECTION[record.tuxedo&.to_sym]
          ]
        end
      end
    end

    def to_yes_or_no(boolean)
      boolean ? 'Yes' : 'No'
    end
  end
end
