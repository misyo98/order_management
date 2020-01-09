namespace :orders do
  desc "Decode html special chars for line items meta fields"
  task decode_meta_fields: :environment do
    puts "Going to update orders metafields"
    LineItem.find_each(batch_size: 100).each do |item|
      item.meta.map do |meta|
        meta['value'] = Nokogiri::HTML.parse(meta['value']).text
      end
      item.update_attribute(:meta, item.meta)
      print '.'
    end
    puts " All done now!"
  end
end
