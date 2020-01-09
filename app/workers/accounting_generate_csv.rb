class AccountingGenerateCsv
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(params)
    items = LineItem.preload(
      :product,
      :tags,
      :refunds,
      order: [:billing, :shipping, :customer]
    ).joins(:order).ransack(params).result
    temp_file = Exporters::Objects::Accountings.new(records: items).call
    new_file = TmpFileManager.save_data_as_csv(temp_file, 'accountings')

    Pusher.trigger('csv-channel', 'csv-generated-event', {
      url: "#{new_file.attachment_url}",
      id: new_file.id
    })

    CleanDownloadedTempFiles.perform_in(10.minutes, id: new_file.id )
  end
end
