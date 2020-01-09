module Importers
  class Objects::TrackingNumbers < Importers::Base
    ATTRIBUTES = {
      m_order_number: 'Order No.',
      tracking_number: 'Tracking Number'
    }.freeze

    private

    attr_accessor :values, :succes_counter, :updated_item_numbers

    def after_initialize
      @values               = []
      @updated_item_numbers = []
      @success_counter      = 0
    end

    def process
      CSV.foreach(file.path, headers: true, quote_char: "\"", row_sep: :auto, col_sep: ';') do |row|
        values << scrape_tracking_values(line: row.to_hash)
      end
      numbers = get_pes_numbers
      items = LineItem.where(m_order_number: numbers)

      update_tracking_numbers(items: items, data: values)
      
      result(success: true, count: @success_counter, message: form_response_message(numbers))
    end

    def scrape_tracking_values(line:)
      pes_number = line[ATTRIBUTES[:m_order_number]]
      tracking_number = line[ATTRIBUTES[:tracking_number]]

      { pes: pes_number, tracking_number: tracking_number }
    end

    def update_tracking_numbers(items:, data:)
      items.each do |item|
        if item.update_attribute(:tracking_number, tracking_number(item.m_order_number))
          item.update_attribute(:shipped_date, Date.today)# TODO: deal date from the file
          item.inbound_number_added(user_id: user_id)
          @success_counter += 1
          updated_item_numbers << item.m_order_number
        end
      end
    end

    def get_pes_numbers
      values.inject([]) { |array, data| array << data[:pes] unless data[:pes].in? array; array }.compact
    end

    def tracking_number(pes)
      hash = values.find { |data_hash| data_hash[:pes] == pes }
      hash&.[]:tracking_number
    end

    def form_response_message(numbers)
      if numbers.count != updated_item_numbers.count
        missing_numbers = numbers - updated_item_numbers
        "Couldn't find items with following manufacturer numbers: #{missing_numbers.join(', ')}"
      else
        'All items were updated'
      end
    end
  end
end
