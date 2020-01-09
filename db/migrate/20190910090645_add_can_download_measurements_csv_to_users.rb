class AddCanDownloadMeasurementsCsvToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_download_measurements_csv, :boolean
  end
end
