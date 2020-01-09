module Importers
  class Objects::RealCogs < Importers::Base
    REAL_COGS_ATTRIBUTES = {
      manufacturer_id:  'Manufacturer ID', 
      order_number:     'Order No', 
      name:             'Name', 
      country:          'Country', 
      product_rc:       'Product RC', 
      construction:     'Construction', 
      meters:           'Meters', 
      fabric:           'Fabric', 
      product_group:    'Product Group', 
      cogs_rc_usd:      'COGS RC USD', 
      order_date:       'Order Date', 
      deal_date:        'Deal date'
    }.freeze

    private

    def process
      real_cogs = []

      CSV.foreach(file.path, headers: true, quote_char: "\"", row_sep: :auto, col_sep: ';') do |row|
        attributes = scrape_attributes(line: row.to_hash, attributes_hash: REAL_COGS_ATTRIBUTES)
        real_cogs << RealCog.new(attributes)
      end

      RealCog.import real_cogs

      result(success: true, count: real_cogs.count)
    end
  end
end
