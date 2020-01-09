task set_fabric_code: :environment do
  batch_size = 1000
  0.step(LineItem.count, batch_size).each do |offset|
    LineItem.all.offset(offset).limit(batch_size).each do |item|
      fabric_hash = item.meta.detect { |hash| hash['key'].in? LineItemDecorator::FABRIC_METAS }
      item.update_attribute(:fabric_code_value, fabric_hash['value']) if fabric_hash
    end
    puts "Done #{offset} line items!"
  end
end