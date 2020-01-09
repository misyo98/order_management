namespace :accounting do
  desc 'Upload csv file to Google Store'
  task upload_csv: :environment do
    GoogleCloud::StorageApi.upload_file
  end
end
