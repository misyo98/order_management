desc 'Moves line_items from new_to_be_measured to new state on remind_to_get_measured date'
task remind_to_get_measured: :environment do
  LineItem.with_state('new_to_be_measured').where(remind_to_get_measured: Date.current).find_each(batch_size: 25) do |item|
    item.measured
  end
end
