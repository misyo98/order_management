module Exporters
  class Objects::FabricInfos < Exporters::Base
    private

    def process
      fast_fields_xls
    end

    def fast_fields_xls
      CSV.generate(headers: true) do |csv|
        unless options[:no_header]
          csv << [
            'Order',
            'Fabric Brand',
            'Fabric Book',
            'Fabric Code',
            'RC Fabric Code',
            'Fabric Composition',
            'Fabric Tier Id',
            'Cut-Length?',
            'Manufacturer',
            'Fusible',
            'Premium',
            'Season',
            'Active',
            'USD / m',
            'Fabric addition (USD) / m',
            'Valid From',
            'Shirts',
            'Trousers',
            'Jackets',
            'Waistcoats',
            'Overcoats',
            'Chinos',
            'TrenchCoats'
          ]
        end

        records.each do |record|
          csv << [
            record.order,
            record.fabric_brand&.title,
            record.fabric_book&.title,
            record.fabric_code,
            record.manufacturer_fabric_code,
            record.fabric_composition,
            record.fabric_tier_id,
            to_yes_or_no(record.cut_length?),
            record.manufacturer,
            to_yes_or_no(record.fusible?),
            to_yes_or_no(record.premium?),
            record.season,
            to_yes_or_no(record.active?),
            record.usd_for_meter,
            record.fabric_addition,
            record.valid_from,
            to_yes_or_no(record.enabled_fabric_categories.joins(:fabric_category).where(FabricCategory.arel_table[:title].eq('Shirts')).any?),
            to_yes_or_no(record.enabled_fabric_categories.joins(:fabric_category).where(FabricCategory.arel_table[:title].eq('Trousers')).any?),
            to_yes_or_no(record.enabled_fabric_categories.joins(:fabric_category).where(FabricCategory.arel_table[:title].eq('Jackets')).any?),
            to_yes_or_no(record.enabled_fabric_categories.joins(:fabric_category).where(FabricCategory.arel_table[:title].eq('Waistcoats')).any?),
            to_yes_or_no(record.enabled_fabric_categories.joins(:fabric_category).where(FabricCategory.arel_table[:title].eq('Overcoats')).any?),
            to_yes_or_no(record.enabled_fabric_categories.joins(:fabric_category).where(FabricCategory.arel_table[:title].eq('Chinos')).any?),
            to_yes_or_no(record.enabled_fabric_categories.joins(:fabric_category).where(FabricCategory.arel_table[:title].eq('TrenchCoats')).any?)
          ]
        end
      end
    end

    def to_yes_or_no(boolean)
      boolean ? 'Yes' : 'No'
    end
  end
end
