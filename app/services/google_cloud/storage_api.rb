module GoogleCloud
  class StorageApi < GoogleCloud::API
    BUCKET = 'order-app'.freeze
    FILE_NAME = 'accountings.csv'.freeze

    def self.upload_file(*args)
      new(*args).upload_file
    end

    def upload_file
      get_file

      update_file

      bucket.create_file file_path, FILE_NAME
    end

    private

    attr_reader :last_id

    def bucket
      @bucket = storage.bucket(BUCKET) || storage.create_bucket(BUCKET)
    end

    def file_path
      @file_path ||= File.join(Rails.root, TMP_DIR, FILE_NAME)
    end

    def get_file
      file = bucket.file FILE_NAME
      if file
        file.download file_path
        content = File.read(file_path)
        csv = CSV.parse(content, headers: true)
        last_row = csv.inject({}) do |last_row, row|
          last_row = row
          last_row
        end
        @last_id = last_row['ID'].to_i
      else
        @last_id = 0
      end
    end

    def update_file
      options = { no_header: !last_id.zero? }
      file_path = File.join(Rails.root, TMP_DIR, FILE_NAME)
      csv = File.new(file_path, 'a')
      LineItem.joins(:order).where(LineItem.arel_table[:id].gt(last_id)).find_in_batches(batch_size: 100).with_index do |items, batch|
        options[:no_header] = batch > 0
        data = Exporters::Objects::Accountings.new(records: items, options: options).call
        csv << data if data.is_a? String
      end
      csv.close
    end
  end
end
