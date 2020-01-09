module Importers
  class Objects::Orders < Importers::Base
    ATTRIBUTES = {
      id: 'Id',
      state: 'Status',
      m_order_number: 'Manufacturer order number'
    }.freeze

    private

    def process
      line_items = []

      CSV.foreach(file.path, headers: true, quote_char: "\"", row_sep: :auto, col_sep: ';') do |row|
        attributes = scrape_attributes(line: row.to_hash, attributes_hash: ATTRIBUTES)
        line = LineItem.new(attributes)
        line.valid?
        unless line.errors[:state].empty?
          return result(success: false, error: "State \"<strong>#{line.state}</strong>\" is invalid".html_safe)
        end
        line_items << LineItem.new(attributes)
      end

      LineItem.import line_items, validate: false, on_duplicate_key_update: [:state, :m_order_number]

      result(success: true, count: line_items.count)
    end
  end
end
