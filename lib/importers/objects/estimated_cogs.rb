module Importers
  class Objects::EstimatedCogs < Importers::Base
    ESTIMATED_COGS_ATTRIBUTES = {
      id:                               'ID',
      country:                          'Country',
      category:                         'Category',
      canvas:                           'Canvas',
      cmt:                              'CMT (USD)',
      fabric_consumption:               'Fabric Consumption (m)',
      estimated_inbound_shipping_costs: 'Inbound shipping costs (estimated) USD',
      estimated_duty:                   'Duty (estimated) USD',
      valid_from:                       'Valid From'
    }.freeze

    private

    def process
      estimated_cogs = []

      CSV.foreach(file.path, headers: true, quote_char: "\"", row_sep: :auto, col_sep: ';') do |row|
        attributes = scrape_attributes(line: row.to_hash, attributes_hash: ESTIMATED_COGS_ATTRIBUTES)

        estimated_cogs << EstimatedCog.new(attributes)
      end

      EstimatedCog.import estimated_cogs, on_duplicate_key_update: %i[
        country category canvas cmt fabric_consumption
        estimated_inbound_shipping_costs estimated_duty valid_from
      ]

      result(success: true, count: estimated_cogs.count)
    end
  end
end
