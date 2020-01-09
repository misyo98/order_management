class TmpFileManager
  def self.save_data_as_csv(*attrs)
    new(*attrs).save_data_as_csv
  end

  def initialize(data, name)
    @data = data
    @name = name
  end

  def save_data_as_csv
    path = File.join(Rails.root, 'tmp', 'data')

    FileUtils.mkdir_p(path) unless File.exist?(path)
    tmp_csv = Tempfile.new([name, '.csv'], path)
    tmp_csv.write(data.force_encoding('UTF-8'))
    tmp_csv.rewind
    csv = TempFile.new(attachment: tmp_csv)
    csv.save!

    tmp_csv.unlink
    csv
  end

  private

  attr_reader :data, :name
end
